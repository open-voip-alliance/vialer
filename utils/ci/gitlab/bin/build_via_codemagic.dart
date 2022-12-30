// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:xml/xml.dart';

import '../../ci_utils.dart';

const _codemagicBaseUrl = 'https://api.codemagic.io/builds';

/// The frequency at which api calls will be made when checking the build
/// status.
const _apiQueryInterval = Duration(seconds: 10);

/// Starts a build on Codemagic and will then block until the build has
/// finished.
///
/// This is designed to be run in the Gitlab CI environment but for testing
/// purposes you can run it locally:
///
/// e.g.
///
/// `dart utils/ci/gitlab/build_via_codemagic.dart 5e78b819064d840016d04c7a main main {CODEMAGIC API KEY} 123`
Future<void> main(List<String> args) async {
  final appId = args.getOrEnvVar(0, 'CODEMAGIC_APP_ID');
  final codemagicApiToken = args.getOrEnvVar(3, 'CODEMAGIC_API_TOKEN');

  final buildId = await _startCodemagicBuild(
    apiToken: codemagicApiToken,
    appId: appId,
    workflowId: args.getOrEnvVar(1, 'CODEMAGIC_WORKFLOW'),
    branch: args.getOrEnvVar(2, 'CI_MERGE_REQUEST_SOURCE_BRANCH_NAME'),
    gitlabMergeRequestId: args.getOrEnvVar(4, 'CI_MERGE_REQUEST_IID'),
  );

  _printCodemagicBuildUrl(appId, buildId);

  // Continually fetch the build status from the API until we have found
  // a finished build.
  final build = await _awaitFinishedBuild(
    apiToken: codemagicApiToken,
    buildId: buildId,
  );

  // Check the status of the build and exit with the correct exit code so
  // Gitlab CI will know whether it was successful or not.
  if (build.status == _CodemagicBuildStatus.complete) {
    final testsSuccessful = await _getIntegrationTestResults(buildId: buildId);
    exit(testsSuccessful ? 0 : 1);
  } else if (build.status == _CodemagicBuildStatus.failed) {
    print('Build failed on: ${build.currentStage}');
    _printCodemagicBuildUrl(appId, buildId);
    exit(1);
  }
}

/// Continually query the Codemagic API until we have a build that is considered
/// finished, this could be cancelled, failed or successful.
///
/// The [_apiQueryInterval] will determine how often requests are made to the
/// api.
Future<_CodemagicBuild> _awaitFinishedBuild({
  required String apiToken,
  required String buildId,
}) async {
  final build = await _fetchCodemagicBuild(
    apiToken: apiToken,
    buildId: buildId,
  );

  if (build.status == _CodemagicBuildStatus.pending) {
    print('Codemagic Build: ${build.currentStage}');
    sleep(_apiQueryInterval);
    return await _awaitFinishedBuild(apiToken: apiToken, buildId: buildId);
  }

  return build;
}

void _printCodemagicBuildUrl(String appId, String buildId) =>
    print('For the detailed build log go to: '
        'https://codemagic.io/app/$appId/build/$buildId');

Future<String> _startCodemagicBuild({
  required String apiToken,
  required String appId,
  required String workflowId,
  required String branch,
  required String gitlabMergeRequestId,
}) async =>
    HttpClient()
        .postUrl(Uri.parse(_codemagicBaseUrl))
        .then(
          (request) {
            request.headers.set('x-auth-token', apiToken);
            request.headers.set('Content-Type', 'application/json');
            request.write(
              json.encode(
                {
                  'appId': appId,
                  'workflowId': workflowId,
                  'branch': branch,
                  'environment': {
                    'variables': {
                      'GITLAB_MERGE_REQUEST_IID': gitlabMergeRequestId,
                    },
                  },
                },
              ),
            );

            return request.close();
          },
        )
        .then(readResponse)
        .then(jsonDecode)
        .then((response) => response['buildId'] as String);

Future<_CodemagicBuild> _fetchCodemagicBuild({
  required String apiToken,
  required String buildId,
  bool retry = true,
}) async {
  final build = await HttpClient()
      .getUrl(Uri.parse('$_codemagicBaseUrl/$buildId'))
      .then((request) {
        request.headers.set('x-auth-token', apiToken);
        return request.close();
      })
      .then(readResponse)
      .then(jsonDecode)
      .then((response) => response['build']);

  final status = (build['status'] as String?);

  if (status == null) {
    if (!retry) {
      throw Exception('Unable to fetch codemagic build: [$buildId].');
    }

    // If we weren't able to fetch the build immediately, we will wait briefly
    // and then try again.
    sleep(_apiQueryInterval);
    return _fetchCodemagicBuild(
      apiToken: apiToken,
      buildId: buildId,
      retry: false,
    );
  }

  final buildStatus = status.toCodemagicBuildStatus();

  final buildActions = build['buildActions'] as List<dynamic>;

  // Attempts to find the "action" we are currently on (i.e. the build stage)
  // so this information can be printed.
  if (buildActions.isNotEmpty) {
    // To find the current action we want to filter the build actions
    // to those that haven't been started or skipped.
    final currentActions = buildActions.where(
      (action) =>
          action['startedAt'] != null && action['startedAt'] != 'skipped',
    );

    if (currentActions.isNotEmpty) {
      return _CodemagicBuild(
        buildStatus,
        currentAction: currentActions.last['name'] as String,
      );
    }
  }

  return _CodemagicBuild(buildStatus);
}

/// Returns true if tests succeeded, false otherwise.
Future<bool> _getIntegrationTestResults({required String buildId}) async {
  final gcloudTar = File('gcloud.tar.gz');

  // Downloading gcloud binaries.
  await HttpClient()
      .getUrl(
        Uri.parse(
          'https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/'
          'google-cloud-sdk-357.0.0-linux-x86_64.tar.gz',
        ),
      )
      .then((rq) => rq.close())
      .then((r) => r.pipe(gcloudTar.openWrite()));

  await Process.run('tar', ['xf', gcloudTar.path]).printResult();

  final gcloudKey = File('gcloud-key.json');
  gcloudKey.writeAsString(
    utf8.decode(
      base64.decode(Platform.environment['GCLOUD_KEY']!),
    ),
  );

  final bin = 'google-cloud-sdk/bin';

  // Login to Google.
  await Process.run(
    '$bin/gcloud',
    [
      'auth',
      'activate-service-account',
      '--key-file=${gcloudKey.path}',
    ],
    runInShell: true,
  ).printResult();

  final projectId = 'vialer-fcm-423a9';

  // Set Google Cloud project we're working with.
  await Process.run(
    '$bin/gcloud',
    [
      '--quiet',
      'config',
      'set',
      'project',
      projectId,
    ],
    runInShell: true,
  ).printResult();

  final testResultsDir = Directory('test_results');
  await testResultsDir.create();

  // Download test result XML files.
  await Process.run(
    '$bin/gsutil',
    [
      'rsync',
      '-r',
      '-x',
      r'^(?!.*test_result_[0-9]+.xml$).*',
      'gs://$projectId.appspot.com/$buildId',
      testResultsDir.path,
    ],
    runInShell: true,
  ).printResult();

  // Delete all test files from Google Cloud.
  await Process.run(
    '$bin/gsutil',
    [
      'rm',
      '-r',
      'gs://$projectId.appspot.com/$buildId',
    ],
    runInShell: true,
  ).printResult();

  final testResults = Glob('**test_result_*.xml', recursive: true).list(
    root: testResultsDir.path,
  );

  await for (final testResult in testResults) {
    final doc = XmlDocument.parse(await File(testResult.path).readAsString());

    // If zero tests were done, something went wrong and we should fail.
    if (doc.rootElement.attributes
        .any((a) => a.name.local == 'tests' && a.value == '0')) {
      print('Something went wrong while running test: ${testResult.dirname}');
      return false;
    }

    for (final testCase in doc.findAllElements('testcase')) {
      if (testCase.childElements.any((e) => e.name.local == 'failure')) {
        return false;
      }
    }
  }

  return true;
}

class _CodemagicBuild {
  final _CodemagicBuildStatus status;
  final String currentStage;

  const _CodemagicBuild(
    this.status, {
    String? currentAction,
  }) : currentStage = currentAction ?? 'unknown';
}

enum _CodemagicBuildStatus {
  complete,
  failed,
  pending,
}

extension on String {
  _CodemagicBuildStatus toCodemagicBuildStatus() {
    switch (this) {
      case 'finished':
        return _CodemagicBuildStatus.complete;
      case 'failed':
      case 'canceled':
        return _CodemagicBuildStatus.failed;
      default:
        return _CodemagicBuildStatus.pending;
    }
  }
}

extension on List<String> {
  String getOrEnvVar(int index, String envVar) {
    if (length >= index + 1) {
      return elementAt(index);
    } else {
      return Platform.environment[envVar]!;
    }
  }
}

extension on Future<ProcessResult> {
  Future<void> printResult() async {
    final result = await this;
    print(result.stdout);
    print(result.stderr);
  }
}

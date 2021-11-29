import 'dart:convert';
import 'dart:io';

import '../ci_utils.dart';

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
    exit(0);
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

  final status = (build['status'] as String).toCodemagicBuildStatus();

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
        status,
        currentAction: currentActions.last['name'] as String,
      );
    }
  }

  return _CodemagicBuild(status);
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

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;

/// This script updates the description of a GitLab merge request with a
/// Codemagic build status link.
///
/// Arguments:
/// --merge-request-id: the ID of the merge request to update (required)
/// --gitlab-api-token: the GitLab API token (required)
/// --build-number: the Codemagic build number (required)
/// --project-id: the Codemagic project ID (required)
/// --build-id: the Codemagic build ID (required))
void main(List<String> arguments) async {
  final argParser = ArgParser()
    ..addOption('merge-request-id', help: 'Merge request ID')
    ..addOption('gitlab-api-token', help: 'GitLab API token')
    ..addOption('build-number', help: 'Codemagic build number')
    ..addOption('project-id', help: 'Codemagic project ID')
    ..addOption('build-id', help: 'Codemagic build ID');

  final args = argParser.parse(arguments);

  if (args['merge-request-id'] == null ||
      args['gitlab-api-token'] == null ||
      args['build-number'] == null ||
      args['project-id'] == null ||
      args['build-id'] == null) {
    throw Exception(argParser.usage);
  }

  final mergeRequestId = args['merge-request-id']!;
  final gitlabApiToken = args['gitlab-api-token']!;
  final buildNumber = args['build-number']!;
  final projectId = args['project-id']!;
  final buildId = args['build-id']!;

  final url = Uri.parse(
    'https://gitlab.wearespindle.com/'
    'api/v4/projects/105/merge_requests/$mergeRequestId',
  );
  final headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    'Private-Token': gitlabApiToken.toString(),
  };

  final buildInformation = '''
[Codemagic: Latest Build ($buildNumber)](https://codemagic.io/app/$projectId/build/$buildId)
''';

  final response = await http.get(url, headers: headers);

  if (response.statusCode != 200) return;

  final currentDescription = jsonDecode(response.body)['description'] as String;

  final newDescription = currentDescription.containsBuildInformationAlready
      ? currentDescription.replaceExistingBuildInformation(buildInformation)
      : currentDescription.appendBuildInformation(buildInformation);

  await updateWithNewDescription(url, headers, newDescription);
}

extension on String {
  bool get containsBuildInformationAlready => contains('[Codemagic:');

  String replaceExistingBuildInformation(String buildInformation) =>
      replaceAllMapped(
        RegExp(r'^\[Codemagic\:.+$', multiLine: true),
        (match) => '$buildInformation',
      );

  String appendBuildInformation(String buildInformation) =>
      '$this\n\n$buildInformation';
}

Future<http.Response> updateWithNewDescription(
  Uri url,
  Map<String, String> headers,
  String newDescription,
) =>
    http.put(
      url,
      headers: headers,
      body: json.encode({
        'description': newDescription,
      }),
    );

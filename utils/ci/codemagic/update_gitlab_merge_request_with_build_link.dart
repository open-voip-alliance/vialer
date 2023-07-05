import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as timezoneInit;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

/// This script updates the description of a GitLab merge request with a
/// Codemagic build status link.
void main(List<String> arguments) async {
  final argParser = ArgParser()
    ..addOption('merge-request-id', help: 'The merge request id from gitlab')
    ..addOption('gitlab-api-token', help: 'An api token for Gitlab')
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

  final mergeRequestId = args['merge-request-id'] as String;
  final gitlabApiToken = args['gitlab-api-token'] as String;
  final buildNumber = args['build-number'] as String;
  final projectId = args['project-id'] as String;
  final buildId = args['build-id'] as String;

  final url = Uri.parse('''
https://gitlab.wearespindle.com/api/v4/projects/105/merge_requests/$mergeRequestId
''');

  final headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    'Private-Token': gitlabApiToken,
  };

  // Using a multi-line string as it is easier to read what is being produced,
  // rather than splitting it.
  final buildInformation = '''
[Codemagic: Latest Build ($buildNumber, $_time)](https://codemagic.io/app/$projectId/build/$buildId)
''';

  final response = await http.get(url, headers: headers);

  if (response.statusCode != 200) return;

  final currentDescription = (jsonDecode(response.body)
      as Map<String, dynamic>)['description'] as String;

  final newDescription = currentDescription.containsBuildInformationAlready
      ? currentDescription.replaceExistingBuildInformation(buildInformation)
      : currentDescription.appendBuildInformation(buildInformation);

  await _updateWithNewDescription(url, headers, newDescription);
}

extension on String {
  bool get containsBuildInformationAlready => contains('[Codemagic:');

  String replaceExistingBuildInformation(String buildInformation) =>
      replaceAllMapped(
        RegExp(r'^\[Codemagic:.+$', multiLine: true),
        (match) => buildInformation,
      );

  String appendBuildInformation(String buildInformation) =>
      '$this\n\n$buildInformation';
}

Future<http.Response> _updateWithNewDescription(
  Uri url,
  Map<String, String> headers,
  String newDescription,
) =>
    http.put(
      url,
      headers: headers,
      body: json.encode(
        {
          'description': newDescription,
        },
      ),
    );

String get _time {
  timezoneInit.initializeTimeZones();
  initializeDateFormatting();
  return DateFormat('dd/MM/yyyy H:mm:ss', 'en')
      .format(tz.TZDateTime.now(tz.getLocation('Europe/Amsterdam')));
}

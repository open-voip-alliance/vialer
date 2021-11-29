import 'dart:convert';
import 'dart:io' show HttpClient, Platform, exit;

import '../ci_utils.dart';

Future<void> main(List<String> args) async {
  final env = Platform.environment;

  final mergeRequestId = env['CI_MERGE_REQUEST_IID'];
  final apiToken = env['GITLAB_API_TOKEN'];
  final url = Uri.parse(
    'https://gitlab.wearespindle.com/api/v4/projects/105/merge_requests/$mergeRequestId',
  );

  final regex = RegExp(
    r'^(.*)\[Codemagic: Latest Build \(\d*\)\]\(https.*\).*',
    dotAll: true,
  );

  if (apiToken == null) {
    print('GITLAB_API_TOKEN not found.');
    exit(1);
  }

  final client = HttpClient();
  var request = await client.getUrl(url);
  request.headers.set('Content-Type', 'application/json');
  request.headers.set('Private-Token', apiToken);

  var response = await request.close();

  print('Request MR description.');
  if (response.statusCode != 200) {
    print('Response code: ${response.statusCode}.');
    print(await readResponse(response));
    exit(1);
  }

  final description =
      jsonDecode(await readResponse(response))['description'] as String;

  final match = regex.firstMatch(description);
  if (match != null) {
    print('Previous build information found, updating MR description..');

    request = await client.putUrl(url);
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Private-Token', apiToken);
    request.write(jsonEncode({'description': match.group(1)}));
    response = await request.close();

    if (response.statusCode == 200) {
      print('Updated MR description.');
    } else {
      print('Response code: ${response.statusCode}.');
      print(await readResponse(response));
      exit(1);
    }
  } else {
    print('No build information found, so not updating MR description.');
  }

  exit(0);
}

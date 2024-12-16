// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io' show HttpClient, Platform, exit;

import '../ci_utils.dart';

Future<void> main(List<String> args) async {
  final env = Platform.environment;

  final version = env['FCI_TAG'];
  final brand = env['BRAND'];
  // Using the Android key for Segment here, but tracking a version is
  // indifferent to the platform.
  final apiToken = env['SEGMENT_ANDROID_WRITE_KEY'];

  if (version == null || brand == null || apiToken == null) {
    throw ArgumentError(
      'You must provide a valid version, brand and API token. '
      'This can be done via FCI_TAG/BRAND/SEGMENT_ANDROID_KEY env vars.',
    );
  }

  final authorizationHeader = 'Basic ${'$apiToken:'.toBase64()}';
  const identifyUrl = 'https://api.segment.io/v1/identify';
  const trackUrl = 'https://api.segment.io/v1/track';
  const anonymousId = 'vialer_update_user';
  const event = 'update-released';

  // Identify anonymous user.
  await sendToSegment(
    identifyUrl,
    authorizationHeader,
    <String, dynamic>{'anonymousId': anonymousId},
  );

  // Track the new release.
  final data = {
    'anonymousId': anonymousId,
    'event': event,
    'properties': {'brand': brand, 'version': version},
  };
  await sendToSegment(trackUrl, authorizationHeader, data);

  print('$version tracked for $brand');
  exit(0);
}

Future<void> sendToSegment(
  String url,
  String authorizationHeader,
  Map<String, dynamic> data,
) async {
  final client = HttpClient();
  final request = await client.postUrl(Uri.parse(url));

  request.headers.set('Content-Type', 'application/json');
  request.headers.set('Authorization', authorizationHeader);

  request.write(jsonEncode(data));

  final response = await request.close();
  if (response.statusCode != 200) {
    print('Response code: ${response.statusCode}.');
    print(await readResponse(response));

    exit(1);
  }
}

extension on String {
  String toBase64() => base64.encode(utf8.encode(this));
}

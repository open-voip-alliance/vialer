import 'dart:io';

final root = Directory(Platform.environment['SRCROOT']!);

Future<void> writeXconfigFile({
  required String name,
  required Map<String, String> values,
}) async {
  final file = File('${root.path}/Flutter/$name.xcconfig');

  await file.writeAsString(
    values.entries.map((e) => '${e.key}=${e.value}').join('\n'),
  );
}

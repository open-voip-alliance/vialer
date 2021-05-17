import 'dart:io';

final root = Directory(Platform.environment['SRCROOT']!);

/// Assumes the `dart-define`s string is the first argument.
Map<String, String> parseDartDefinesFromArguments(Iterable<String> arguments) {
  return parseDartDefines(arguments.isNotEmpty ? arguments.first : null);
}

Map<String, String> parseDartDefines(String? input) {
  if (input == null || input.isEmpty) {
    return {};
  }

  return Map.fromEntries(
    input.split(',').map((keyValuePair) {
      final split = keyValuePair.split('%3D'); // %3D is '=' encoded
      return MapEntry(split[0], split[1]);
    }),
  );
}

Future<void> writeXconfigFile({
  required String name,
  required Map<String, String> values,
}) async {
  final file = File('${root.path}/Flutter/$name.xconfig');

  await file.writeAsString(
    values.entries.map((e) => '${e.key}=${e.value}').join('\n'),
  );
}

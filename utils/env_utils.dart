import 'dart:io';

Future<Map<String, String>> readEnv(String path) async {
  return Map.fromEntries(
    await File(path).readAsLines().then(
          (lines) => lines
              .where((line) => line.isNotEmpty && !line.startsWith('//'))
              .map(
            (line) {
              final split = line.split('=');
              return MapEntry(split[0], split[1]);
            },
          ),
        ),
  );
}

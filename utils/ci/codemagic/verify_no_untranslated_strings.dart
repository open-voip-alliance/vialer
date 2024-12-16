import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart';

import 'prepare_release_notes.dart';

final _nullPattern = RegExp(": ?~");

Future<void> main(List<String> args) async {
  final filesWithMissingTranslations = <File, List<_MissingTranslation>>{};

  if (messagesLocalizationMap.messageFiles.isEmpty) {
    stderr.writeln('Unable to find any message files');
    exit(1);
  }

  for (final file in messagesLocalizationMap.messageFiles) {
    final lines = file.lines;

    for (final (line, lineNumber) in lines) {
      if (!line.contains(_nullPattern)) continue;

      final entries =
          filesWithMissingTranslations[file] ?? <_MissingTranslation>[];

      entries.add(
        (
          line.replaceAll(_nullPattern, '').trim(),
          lineNumber,
          file,
        ),
      );

      filesWithMissingTranslations[file] = entries;
    }
  }

  _outputMissingTranslationsToConsole(filesWithMissingTranslations);

  exit(filesWithMissingTranslations.isNotEmpty ? 1 : 0);
}

void _outputMissingTranslationsToConsole(
  Map<File, List<_MissingTranslation>> files,
) {
  files.forEach((file, missing) {
    stderr.writeln(
      "Missing ${missing.length} translations in ${file.fileName}",
    );
  });

  files.forEach((file, missing) {
    missing.forEach(
      (missingTranslation) => stderr.writeln(
        missingTranslation.asConsoleOutput(),
      ),
    );
  });
}

typedef _MissingTranslation = (String, int, File);

extension on _MissingTranslation {
  String asConsoleOutput() =>
      "File [${$3.fileName}] is missing translation for key [${$1}] on line [${$2}]";
}

extension on File {
  String get fileName => basename(path);

  Iterable<(String, int)> get lines => readAsLinesSync().asMap().entries.map(
        (e) => (e.value, e.key + 1),
      );
}

extension on Map<String, List<String>> {
  Iterable<File> get messageFiles => values.flattened.map(
        (name) => File(
          "lib/presentation/resources/$name.yaml",
        ),
      );
}

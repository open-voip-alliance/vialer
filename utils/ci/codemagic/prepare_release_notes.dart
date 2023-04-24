import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:path/path.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// A mapping between the supported language and the language codes used by the
/// app/play store. e.g. dutch.txt will produce nl_NL.txt and nl.txt
const localizationMap = {
  'english.txt': [
    'en-US',
  ],
  'dutch.txt': [
    'nl-NL',
    'nl',
  ],
};

/// The messages files that should be updated with the release notes.
const messagesLocalizationMap = {
  'english.txt': ['messages.i18n', 'messages_de.i18n'],
  'dutch.txt': ['messages_nl.i18n'],
};

/// The path to where the messages.yaml files are stored.
const messagesFileDirectory = 'lib/app/resources/';

const rawReleaseNotesPath = 'release_notes';

/// The maximum number of characters supported by the store-fronts, this check
/// will be performed here as soon as possible so we don't risk partially
/// publishing.
const maxAllowedCharactersInReleaseNotes = 500;

/// Any release notes containing a term in this list will not be published to
/// the app stores. They will still be available in-app.
const releaseNotesPublishingBlocklist = [
  'android',
];

/// Finds the appropriate release notes for the current tag and moves the files
/// into the root project directory for Codemagic to publish.
///
/// Expected release notes location is: release_notes/TAG/BRAND
/// e.g. release_notes/v7.0.0/vialer
///
/// By default this will fallback to VIALER if there are no release notes
/// provided for the specified brand.
///
/// The tag and brand information must either be passed to the script via
/// command line arguments:
///
/// e.g. dart prepare_release_notes.dart v7.0.0 vialer
///
/// or if these aren't present the env vars set in the Codemagic environment
/// will be used.
Future<void> main(List<String> args) async {
  final tag = args.elementAtOrNull(0) ?? Platform.environment['FCI_TAG'];
  final brand = args.elementAtOrNull(1) ?? Platform.environment['BRAND'];

  if (tag == null || brand == null) {
    throw ArgumentError(
      'You must provide a valid tag and brand. '
      'This can be done as arguments or via FCI_TAG/BRAND env vars.',
    );
  }

  final directory = await findReleaseNotesDirectory(
    tag: tag,
    brand: brand,
  );

  final files = await directory.list().toList();

  if (files.length <= 0) {
    throw Exception('There are no files in the release notes directory');
  }

  for (var file in files) {
    if (file is File) {
      await generateReleaseNotesForCodemagic(file);
      await updateMessagesFilesWithLatestReleaseNotes(file);
    } else {
      throw Exception('${file.path} is not a file and should not be here.');
    }
  }

  await buildMessageFiles();
  verifyAllReleaseNotesFilesWereGenerated();
}

/// The message files now need to be rebuilt as we have updated the .yaml
/// files.
Future<void> buildMessageFiles() async => Process.run('flutter', [
      'packages',
      'pub',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);

/// We will now update the [messages.i18n.yaml] files with the translated
/// release notes so they can be viewed in the app.
///
/// You must run the command to generate the .dart language files
/// after this has been run.
Future<void> updateMessagesFilesWithLatestReleaseNotes(File file) async {
  final fileName = basename(file.path);
  final mappings = messagesLocalizationMap[fileName] ?? [];

  for (final mapping in mappings) {
    final messagesFile = File('$messagesFileDirectory$mapping.yaml');

    if (!await messagesFile.exists()) {
      throw Exception('${messagesFile.path} does not exist.');
    }

    final yamlEditor = YamlEditor(await messagesFile.readAsString());
    yamlEditor.update(
      ['main', 'update', 'releaseNotes', 'notes'],
      await file.readAsString(),
    );
    messagesFile.writeAsString(yamlEditor.toString());
  }
}

/// Finds the mappings and generates the relevant files for each language.
Future<void> generateReleaseNotesForCodemagic(File file) async {
  final fileName = basename(file.path);
  final mapping = localizationMap[fileName];

  if (mapping == null) {
    throw Exception(
      '${file.path} is not a valid release notes file, '
      'remove it from the directory. '
      'Supported are: ${localizationMap.keys.toList().join(', ')}',
    );
  }

  final releaseNotesCharacterCount = await file.readAsString().then(
        (content) => content.length,
      );

  if (releaseNotesCharacterCount >= maxAllowedCharactersInReleaseNotes) {
    throw Exception(
      '$fileName is $releaseNotesCharacterCount characters long '
      'exceeding the maximum of $maxAllowedCharactersInReleaseNotes.',
    );
  }

  if (releaseNotesCharacterCount <= 0) {
    throw Exception('Unable to publish these notes as $fileName is empty.');
  }

  for (var generatedFilePath in mapping) {
    await file
        .copy(createCodemagicReleaseNotesFileName(generatedFilePath))
        .then(removeReleaseNotesContainingBlocklistedTerm);
  }
}

/// Find the release notes directory. If a fallback brand is provided, the
/// directory for that brand will be used if the specified brand cannot
/// be found.
Future<Directory> findReleaseNotesDirectory({
  required String tag,
  required String brand,
  String? fallbackBrand = 'vialer',
}) async {
  final path = '$rawReleaseNotesPath/$tag/$brand';

  final directory = Directory(path);

  if (!await directory.exists()) {
    if (fallbackBrand == null) {
      throw Exception(
        'Unable to find release notes directory ($path) '
        'make sure it has been created for this tag.',
      );
    }

    return findReleaseNotesDirectory(
      tag: tag,
      brand: fallbackBrand,
      fallbackBrand: null,
    );
  }

  return directory;
}

Future<void> verifyAllReleaseNotesFilesWereGenerated() async {
  final expectedFiles = localizationMap.values.expand((element) => element);

  for (var expectedFile in expectedFiles) {
    final expectedFilePath = createCodemagicReleaseNotesFileName(expectedFile);

    final file = await File(expectedFilePath);

    if (!await file.exists()) {
      throw Exception(
        'Unable to find expected file $expectedFilePath, something went wrong.',
      );
    }
  }
}

/// Creates the file name expected by Codemagic for the release notes files.
String createCodemagicReleaseNotesFileName(String name) {
  /// The prefix that Codemagic expects to be at the front of the release notes
  /// file. e.g. release_notes_en_US.txt
  const generatedFilePrefix = 'release_notes_';

  /// The file extension that Codemagic is expecting the release notes files
  /// to all have.
  const generatedFileExtension = '.txt';

  return '$generatedFilePrefix$name$generatedFileExtension';
}

Future<void> removeReleaseNotesContainingBlocklistedTerm(File file) => file
    .readAsLines()
    .then(
      (notes) => notes.where(
        (note) {
          for (var term in releaseNotesPublishingBlocklist) {
            if (note.toLowerCase().contains(term.toLowerCase())) {
              return false;
            }
          }

          return true;
        },
      ),
    )
    .then((notes) => notes.join('\n'))
    .then((notes) => file.writeAsString(notes));

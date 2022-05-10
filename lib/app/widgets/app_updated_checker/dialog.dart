import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../resources/localizations.dart';

class ReleaseNotesDialog extends StatelessWidget {
  final String releaseNotes;
  final String version;

  const ReleaseNotesDialog({
    required this.releaseNotes,
    required this.version,
  });

  @override
  Widget build(BuildContext context) {
    final notes = const LineSplitter()
        .convert(releaseNotes)
        .removeReleaseNotesForOtherPlatforms()
        .removePlatformPrefix()
        .where((note) => note.isNotEmpty)
        .map((note) => note.replaceFirst('-', '•'))
        .toList(growable: true);

    if (notes.isEmpty) {
      notes.add('• ${context.msg.releaseNotes.noneForPlatform}');
    }

    return AlertDialog(
      title: Text(version),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            ...notes.map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(note),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(context.msg.generic.button.done),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

extension on List<String> {
  List<String> removeReleaseNotesForOtherPlatforms() => where(
        (note) => !note
            .toLowerCase()
            .contains('${Platform.isIOS ? 'android' : 'ios'}:'),
      ).toList();

  List<String> removePlatformPrefix() => map(
        (note) => note
            .replaceFirst(
              RegExp('(ios|android):', caseSensitive: false),
              '',
            )
            .trim(),
      ).toList();
}

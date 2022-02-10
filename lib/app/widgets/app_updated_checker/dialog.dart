import 'dart:convert';

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
        .map((note) => note.replaceFirst('-', '•'));

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

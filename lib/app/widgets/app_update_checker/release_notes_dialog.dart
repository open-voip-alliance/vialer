import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../resources/localizations.dart';
import '../../resources/theme.dart';
import '../../util/conditional_capitalization.dart';
import '../stylized_dialog.dart';

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
      notes.add('• ${context.msg.main.update.releaseNotes.noneForPlatform}');
    }

    return StylizedDialog(
      headerIcon: FontAwesomeIcons.star,
      title: context.msg.main.update.releaseNotes.header.title(
        context.brand.appName,
      ),
      subtitle: context.msg.main.update.releaseNotes.header.subtitle(version),
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
      closeButtonText: Text(
        context.msg.generic.button.close.toUpperCaseIfAndroid(context),
      ),
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

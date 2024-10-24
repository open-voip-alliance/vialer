import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../../../../../data/models/business_availability/temporary_redirect/temporary_redirect.dart';

class TemporaryRedirectExplanation extends StatelessWidget {
  const TemporaryRedirectExplanation({
    required this.currentDestination,
    required this.endsAt,
    this.hasDestinations = true,
    super.key,
  });
  final TemporaryRedirectDestination? currentDestination;
  final DateTime? endsAt;
  final bool hasDestinations;

  String _voicemailText(BuildContext context) =>
      currentDestination?.displayName ??
      context.msg.main.temporaryRedirect.explanation.selectVoicemail;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: hasDestinations,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: context.msg.main.temporaryRedirect.explanation.start,
            ),
            if (currentDestination is Voicemail)
              TextSpan(
                text: ' ${_voicemailText(context)} ',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            const TextSpan(text: ' '),
            TextSpan(
              text: context.msg.main.temporaryRedirect.explanation.end(
                endsAt.toTemporaryRedirectFormat(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on DateTime? {
  String toTemporaryRedirectFormat() => this != null
      ? DateFormat('EEEE d-M-y HH:mm', Platform.localeName)
          .format(this!.toLocal())
      : '??';
}

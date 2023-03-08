import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../../../resources/localizations.dart';

class TemporaryRedirectExplanation extends StatelessWidget {
  final TemporaryRedirectDestination? currentDestination;
  final DateTime endsAt;

  const TemporaryRedirectExplanation({
    super.key,
    required this.currentDestination,
    required this.endsAt,
  });

  String _voicemailText(BuildContext context) =>
      currentDestination?.displayName ??
      context.msg.main.temporaryRedirect.explanation.selectVoicemail;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
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
          if (currentDestination is Unknown) const TextSpan(text: ' '),
          TextSpan(
            text: context.msg.main.temporaryRedirect.explanation.end(
              endsAt.toTemporaryRedirectFormat(),
            ),
          ),
        ],
      ),
    );
  }
}

extension on DateTime {
  String toTemporaryRedirectFormat() =>
      DateFormat('E d-M-y H:m').format(toLocal());
}

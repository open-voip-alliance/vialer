import 'package:flutter/material.dart';

import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../../../resources/localizations.dart';

class TemporaryRedirectExplanation extends StatelessWidget {
  final TemporaryRedirectDestination? currentDestination;

  /// When enabled, will include a hint to select a destination if
  /// one isn't chosen.
  final bool enableHint;

  const TemporaryRedirectExplanation({
    super.key,
    required this.currentDestination,
    this.enableHint = true,
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
            text: context.msg.main.temporaryRedirect.explanation.end,
          ),
        ],
      ),
    );
  }
}

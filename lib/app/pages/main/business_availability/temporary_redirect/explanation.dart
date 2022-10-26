import 'package:flutter/material.dart';

import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../../../resources/localizations.dart';

class TemporaryRedirectExplanation extends StatelessWidget {
  final TemporaryRedirectDestination currentDestination;

  const TemporaryRedirectExplanation({
    super.key,
    required this.currentDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: context.msg.main.temporaryRedirect.explanation.start,
          ),
          TextSpan(
            text: currentDestination.displayName,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          TextSpan(
            text: context.msg.main.temporaryRedirect.explanation.end,
          ),
        ],
      ),
    );
  }
}

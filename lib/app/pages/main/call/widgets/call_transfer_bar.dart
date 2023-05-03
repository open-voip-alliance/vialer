import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';

class CallTransferBar extends StatelessWidget {
  const CallTransferBar({required this.text, super.key});

  final Widget text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: context.brand.theme.colors.primaryGradientStart,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  text,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CallTransferInProgressBar extends StatelessWidget {
  const CallTransferInProgressBar({required this.inactiveCall, super.key});

  final Call inactiveCall;

  @override
  Widget build(BuildContext context) {
    return CallTransferBar(
      text: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: inactiveCall.remotePartyHeading,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' - ${inactiveCall.prettyDuration} - '),
            TextSpan(
              text: inactiveCall.isOnHold
                  ? context.msg.main.call.ongoing.state.callOnHold
                  : context.msg.main.call.ongoing.state.callEnded,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_lib/call/call.dart';

import '../../../../resources/localizations.dart';
import '../../../../util/brand.dart';

class CallTransferBar extends StatelessWidget {
  final Widget text;

  const CallTransferBar({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: context.brand.theme.primaryGradientStartColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
  final Call inactiveCall;

  const CallTransferInProgressBar({required this.inactiveCall});

  @override
  Widget build(BuildContext context) {
    return CallTransferBar(
      text: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${inactiveCall.remotePartyHeading}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: '- ${inactiveCall.prettyDuration} - '),
            TextSpan(
              text: inactiveCall.isOnHold
                  ? context.msg.main.call.state.callOnHold
                  : context.msg.main.call.state.callEnded,
            ),
          ],
        ),
      ),
    );
  }
}

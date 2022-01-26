import 'package:flutter/material.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../widgets/t9_dial_pad.dart';
import 'call_transfer_bar.dart';

class CallTransfer extends StatelessWidget {
  final Call activeCall;
  final Function(String) onTransferTargetSelected;

  CallTransfer({
    required this.activeCall,
    required this.onTransferTargetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final transferToStart =
        '${context.msg.main.call.ongoing.state.transferToStart} ';
    final transferToEnd =
        ' ${context.msg.main.call.ongoing.state.transferToEnd}';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: context.brand.theme.primaryGradient,
          ),
          child: SafeArea(
            child: CallTransferBar(
              text: RichText(
                text: TextSpan(children: [
                  TextSpan(text: transferToStart),
                  TextSpan(
                    text: '${activeCall.remotePartyHeading}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: transferToEnd,
                  ),
                ]),
              ),
            ),
          ),
        ),
        Expanded(
          child: T9DialPad(
            callButtonIcon: VialerSans.transfer,
            callButtonColor: context.brand.theme.colors.green1,
            onCallButtonPressed: onTransferTargetSelected,
          ),
        ),
      ],
    );
  }
}

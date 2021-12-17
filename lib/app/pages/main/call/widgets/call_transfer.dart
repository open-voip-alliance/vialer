import 'package:flutter/cupertino.dart';
import 'package:flutter_phone_lib/call/call.dart';

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
                  TextSpan(
                      text: '${context.msg.main.call.state.transferToStart} '),
                  TextSpan(
                    text: '${activeCall.remotePartyHeading}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text: ' ${context.msg.main.call.state.transferToEnd}'),
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

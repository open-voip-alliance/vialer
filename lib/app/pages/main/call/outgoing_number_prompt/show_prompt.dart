import 'package:flutter/material.dart';
import 'package:vialer/app/pages/main/call/outgoing_number_prompt/widget.dart';
import 'package:vialer/domain/calling/outgoing_number/should_prompt_user_for_outgoing_number.dart';

import '../../../../../domain/calling/outgoing_number/outgoing_number.dart';

/// Pops this widget as a dialog so the user can change their outgoing number.
Future<void> showOutgoingNumberPrompt(
  BuildContext context,
  String destination,
  void Function(OutgoingNumber?) callback,
) async {
  if (!ShouldPromptUserForOutgoingNumber()(destination: destination)) {
    return callback(null);
  }

  final outgoingNumber = await showDialog<OutgoingNumber>(
    context: context,
    builder: (_) {
      return SimpleDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        contentPadding: EdgeInsets.symmetric(vertical: 10),
        children: [
          OutgoingNumberPrompt(
            onOutgoingNumberConfigured: (outgoingNumber) => Navigator.of(
              context,
              rootNavigator: true,
            ).pop(outgoingNumber),
          ),
        ],
      );
    },
  );

  if (outgoingNumber != null) {
    callback(outgoingNumber);
  }
}

import 'package:flutter/material.dart';
import 'package:vialer/app/pages/main/call/outgoing_number_prompt/widget.dart';
import 'package:vialer/domain/user/get_logged_in_user.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/legacy/storage.dart';
import '../../../../../domain/user/settings/call_setting.dart';

/// Pops this widget as a dialog so the user can change their outgoing number.
Future<void> showOutgoingNumberPrompt(
  BuildContext context,
  void Function(OutgoingNumber?) callback,
) async {
  final user = GetLoggedInUserUseCase()();
  final storageRepository = dependencyLocator<StorageRepository>();

  if (!user.permissions.canChangeOutgoingNumber ||
      storageRepository.doNotShouldOutgoingNumberSelector ||
      user.client.outgoingNumbers.length < 2) {
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

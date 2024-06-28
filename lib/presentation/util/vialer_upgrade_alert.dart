import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:vialer/global.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:vialer/presentation/util/debug.dart';
import 'package:vialer/presentation/util/loggable.dart';

/// The duration for which the SnackBar will be displayed before being
/// automatically dismissed.
const snackBarDuration = Duration(seconds: 15);

class GentleUpdateReminder extends UpgradeAlert {
  GentleUpdateReminder({required Widget child}) : super(child: child);

  @override
  _GentleUpdateReminder createState() => _GentleUpdateReminder();
}

class _GentleUpdateReminder extends UpgradeAlertState with Loggable {
  void _onUpdateButtonPressed() {
    onUserUpdated(context, false);
    track('app-upgrade-snack-bar-pressed');
  }

  @override
  void showTheDialog({
    // We are just building our own SnackBar here, we won't be using any of
    // these parameters.
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    if (inDebugMode) {
      logger.info('Skipping upgrade alert in debug mode. [$message]');
      return;
    }

    final backgroundColor = context.brand.theme.colors.buttonBackground;
    final contentColor = context.brand.theme.colors.raisedColoredButtonText;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: snackBarDuration,
        content: Text(
          context.msg.main.updateReminder.title,
          style: TextStyle(color: contentColor),
        ),
        backgroundColor: backgroundColor,
        action: SnackBarAction(
          label: context.msg.main.updateReminder.button,
          textColor: contentColor,
          onPressed: _onUpdateButtonPressed,
        ),
      ),
    );
  }
}

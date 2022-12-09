import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/user/settings/app_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';
import '../../../../../util/conditional_capitalization.dart';
import '../../cubit.dart';
import 'value.dart';
import 'widget.dart';

class RemoteLoggingTile extends StatelessWidget {
  final User user;

  const RemoteLoggingTile(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      label: Text(context.msg.main.settings.list.debug.remoteLogging.title),
      description: Text(
        context.msg.main.settings.list.debug.remoteLogging.description,
      ),
      child: BoolSettingValue(
        user.settings,
        AppSetting.remoteLogging,
        onChanged: (context, key, value) {
          // Show a popup, asking if the user wants to send their locally
          // saved logs to the remote.
          if (value == true) {
            showDialog(
              context: context,
              builder: (_) => _RemoteLoggingSendLogsDialog(
                cubit: context.read<SettingsCubit>(),
              ),
            );
          }
          defaultOnChanged(context, key, value);
        },
      ),
    );
  }
}

class _RemoteLoggingSendLogsDialog extends StatelessWidget {
  final SettingsCubit cubit;

  const _RemoteLoggingSendLogsDialog({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final title = Text(
      context
          .msg.main.settings.list.debug.remoteLogging.sendToRemoteDialog.title,
    );
    final content = Text(
      context.msg.main.settings.list.debug.remoteLogging.sendToRemoteDialog
          .description,
    );

    final deny = Text(
      context.msg.generic.button.noThanks.toUpperCaseIfAndroid(context),
    );
    final confirm = Text(
      context
          .msg.main.settings.list.debug.remoteLogging.sendToRemoteDialog.confirm
          .toUpperCaseIfAndroid(context),
    );

    void onDenyPressed() => Navigator.pop(context);
    void onConfirmPressed() {
      cubit.sendSavedLogsToRemote();
      Navigator.pop(context);
    }

    if (context.isAndroid) {
      return AlertDialog(
        title: title,
        content: content,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.brand.theme.colors.primary,
            ),
            onPressed: onDenyPressed,
            child: deny,
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.brand.theme.colors.primary,
            ),
            onPressed: onConfirmPressed,
            child: confirm,
          ),
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: title,
        content: content,
        actions: [
          CupertinoDialogAction(
            onPressed: onDenyPressed,
            child: deny,
          ),
          CupertinoDialogAction(
            onPressed: onConfirmPressed,
            child: confirm,
          ),
        ],
      );
    }
  }
}

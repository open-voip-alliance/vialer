import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../../controllers/cubit.dart';
import '../../../pages/troubleshooting.dart';
import 'widget.dart';

class TroubleshootingLinkTile extends StatelessWidget {
  const TroubleshootingLinkTile({super.key});

  void _showTroubleshootingPage(BuildContext context) {
    unawaited(
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) {
            return TroubleshootingSubPage(
              cubit: context.read<SettingsCubit>(),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingLinkTile(
      title: Text(
        context.msg.main.settings.list.advancedSettings.troubleshooting.title,
      ),
      description: Text(
        context.msg.main.settings.list.advancedSettings.troubleshooting
            .description,
      ),
      onTap: () => _showTroubleshootingPage(context),
    );
  }
}

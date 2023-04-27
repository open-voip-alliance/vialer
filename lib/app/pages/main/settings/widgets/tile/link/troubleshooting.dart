import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../resources/localizations.dart';
import '../../../cubit.dart';
import '../../../sub_page/troubleshooting.dart';
import 'widget.dart';

class TroubleshootingLinkTile extends StatelessWidget {
  const TroubleshootingLinkTile({super.key});

  void _showTroubleshootingPage(BuildContext context) {
    unawaited(
      Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
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

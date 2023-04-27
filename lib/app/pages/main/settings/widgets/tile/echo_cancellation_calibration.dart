import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../resources/localizations.dart';
import '../../cubit.dart';
import 'link/widget.dart';

class EchoCancellationCalibrationTile extends StatelessWidget {
  const EchoCancellationCalibrationTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingLinkTile(
      title: Text(
        context.msg.main.settings.list.advancedSettings.troubleshooting.list
            .audio.echoCancellationCalibration.title,
      ),
      description: Text(
        context.msg.main.settings.list.advancedSettings.troubleshooting.list
            .audio.echoCancellationCalibration.description,
      ),
      onTap: () => unawaited(
        context.read<SettingsCubit>().performEchoCancellationCalibration(),
      ),
      showNavigationIndicator: false,
    );
  }
}

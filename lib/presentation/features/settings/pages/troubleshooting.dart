import 'package:flutter/material.dart';
import 'package:vialer/data/models/user/user.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../../../../data/models/user/settings/call_setting.dart';
import '../controllers/cubit.dart';
import '../widgets/tile/category/troubleshooting_audio.dart';
import '../widgets/tile/echo_cancellation_calibration.dart';
import 'settings_subpage.dart';

class TroubleshootingSubPage extends StatelessWidget {
  const TroubleshootingSubPage({
    required this.cubit,
    super.key,
  });

  final SettingsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SettingsSubPage(
      cubit: cubit,
      title:
          context.msg.main.settings.list.advancedSettings.troubleshooting.title,
      child: (state) {
        return ListView(
          children: [
            TroubleshootingAudioCategory(
              children: [
                if (state.user.settings.get(CallSetting.useVoip) == true)
                  const EchoCancellationCalibrationTile(),
              ],
            ),
          ],
        );
      },
    );
  }
}

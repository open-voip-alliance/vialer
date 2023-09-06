import 'package:flutter/material.dart';
import 'package:vialer/domain/user/user.dart';

import '../../../../../domain/user/settings/call_setting.dart';
import '../../../../resources/localizations.dart';
import '../cubit.dart';
import '../widgets/tile/category/troubleshooting_audio.dart';
import '../widgets/tile/echo_cancellation_calibration.dart';
import 'widget.dart';

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

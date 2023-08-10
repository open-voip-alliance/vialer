import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/settings/sub_page/logs.dart';

import '../../../../../domain/user/settings/call_setting.dart';
import '../../../../resources/localizations.dart';
import '../cubit.dart';
import '../widgets/tile/category/troubleshooting_audio.dart';
import '../widgets/tile/category/widget.dart';
import '../widgets/tile/echo_cancellation_calibration.dart';
import '../widgets/tile/link/sub_page.dart';
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
            SettingTileCategory(
              icon: FontAwesomeIcons.computer,
              titleText: context.msg.main.settings.list.advancedSettings
                  .troubleshooting.system.title,
              children: [
                SubPageLinkTile(
                  title: context.msg.main.settings.list.advancedSettings
                      .troubleshooting.logs.title,
                  icon: FontAwesomeIcons.scroll,
                  cubit: cubit,
                  pageBuilder: (_) => const LogSubPage(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

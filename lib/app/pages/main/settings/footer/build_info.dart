import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/user/info/build_info.dart';
import '../../../../../../domain/user/settings/app_setting.dart';
import '../../../../resources/localizations.dart';
import '../cubit.dart';

class BuildInfoPill extends StatefulWidget {
  final BuildInfo buildInfo;

  const BuildInfoPill(this.buildInfo, {Key? key}) : super(key: key);

  @override
  _BuildInfoState createState() => _BuildInfoState();
}

class _BuildInfoState extends State<BuildInfoPill> {
  static const _tapCountToShowHiddenSettings = 10;

  int _tapCount = 0;

  void _onTap() {
    _tapCount++;

    if (_tapCount >= 4 && _tapCount <= _tapCountToShowHiddenSettings) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();

      final gainedAccess = _tapCount == _tapCountToShowHiddenSettings;

      if (gainedAccess) {
        context
            .read<SettingsCubit>()
            .changeSetting(AppSetting.showTroubleshooting, true);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            gainedAccess
                ? context.msg.main.settings.troubleshootingUnlockedPopUp
                : context.msg.main.settings.troubleshootingProgressPopUp(
                    _tapCountToShowHiddenSettings - _tapCount,
                  ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final buildInfo = widget.buildInfo;

        final hasAccessToTroubleshooting = state.user.settings.get(
          AppSetting.showTroubleshooting,
        );

        return GestureDetector(
          onTap: !hasAccessToTroubleshooting ? _onTap : null,
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Chip(
                    label: buildInfo.showDetailed
                        ? _DetailedBuildInfo(buildInfo)
                        : _SimpleBuildInfo(buildInfo),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SimpleBuildInfo extends StatelessWidget {
  final BuildInfo buildInfo;

  const _SimpleBuildInfo(this.buildInfo);

  @override
  Widget build(BuildContext context) {
    return Text(
      '${context.msg.main.settings.list.version} '
      '${buildInfo.version}',
    );
  }
}

class _DetailedBuildInfo extends StatelessWidget {
  final BuildInfo buildInfo;

  const _DetailedBuildInfo(this.buildInfo);

  @override
  Widget build(BuildContext context) {
    const emphasisStyle = TextStyle(fontWeight: FontWeight.bold);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          children: [
            // These don't have to be translated,
            // for developers only.
            TextSpan(
              children: [
                const TextSpan(text: 'Build: '),
                TextSpan(
                  text: buildInfo.buildNumber,
                  style: emphasisStyle,
                ),
              ],
            ),
            if (buildInfo.mergeRequestNumber != null)
              TextSpan(
                children: [
                  const TextSpan(text: ' — MR: '),
                  TextSpan(
                    text: '!${buildInfo.mergeRequestNumber}',
                    style: emphasisStyle,
                  ),
                ],
              ),
            if (buildInfo.branchName != null)
              TextSpan(
                children: [
                  const TextSpan(text: ' — Branch: '),
                  TextSpan(
                    text: buildInfo.branchName,
                    style: emphasisStyle.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            if (buildInfo.tag != null)
              TextSpan(
                children: [
                  const TextSpan(text: ' — Tag: '),
                  TextSpan(
                    text: buildInfo.tag,
                    style: emphasisStyle.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

extension on BuildInfo {
  bool get showDetailed =>
      !isProduction &&
      (mergeRequestNumber != null || branchName != null || tag != null);
}

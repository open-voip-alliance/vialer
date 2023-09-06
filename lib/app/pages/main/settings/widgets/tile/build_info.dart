import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/domain/user/user.dart';

import '../../../../../../../domain/user/info/build_info.dart';
import '../../../../../../../domain/user/settings/app_setting.dart';
import '../../../../../resources/localizations.dart';
import '../../cubit.dart';
import 'category/widget.dart';

class BuildInfoTile extends StatefulWidget {
  const BuildInfoTile(this.buildInfo, {super.key});

  final BuildInfo buildInfo;

  @override
  State<BuildInfoTile> createState() => _BuildInfoTileState();
}

class _BuildInfoTileState extends State<BuildInfoTile> {
  static const _tapCountToShowHiddenSettings = 10;

  int _tapCount = 0;

  void _onTap() {
    _tapCount++;

    if (_tapCount >= 4 && _tapCount <= _tapCountToShowHiddenSettings) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();

      final gainedAccess = _tapCount == _tapCountToShowHiddenSettings;

      if (gainedAccess) {
        unawaited(
          context
              .read<SettingsCubit>()
              .changeSetting(AppSetting.showTroubleshooting, true),
        );
        Navigator.of(context).pop();
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
          child: SettingTileCategory(
            icon: FontAwesomeIcons.circleInfo,
            titleText: !buildInfo.showDetailed
                ? '${context.msg.main.settings.list.version} '
                    '${buildInfo.version}'
                : null,
            title:
                buildInfo.showDetailed ? _DetailedBuildInfo(buildInfo) : null,
            padBottom: true,
          ),
        );
      },
    );
  }
}

class _DetailedBuildInfo extends StatelessWidget {
  const _DetailedBuildInfo(this.buildInfo);

  final BuildInfo buildInfo;

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

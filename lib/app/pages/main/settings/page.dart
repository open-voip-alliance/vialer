import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/build_info.dart';
import '../../../../domain/entities/setting.dart';
import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../routes.dart';
import '../../../util/conditional_capitalization.dart';
import '../../../widgets/stylized_button.dart';
import '../util/stylized_snack_bar.dart';
import '../widgets/header.dart';
import '../widgets/user_data_refresher/cubit.dart';
import 'cubit.dart';
import 'widgets/link_tile.dart';
import 'widgets/tile.dart';
import 'widgets/tile_category.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _availabilityTileKey = GlobalKey();
  final _scrollController = ScrollController();

  Future<void> _goToFeedbackPage(BuildContext context) async {
    final sent = await Navigator.pushNamed(
          context,
          Routes.feedback,
        ) as bool? ??
        false;

    if (sent) {
      showSnackBar(
        context,
        icon: const Icon(VialerSans.check),
        label: Text(context.msg.main.settings.feedback.snackBar),
      );
    }

    context.read<SettingsCubit>().refresh();
  }

  void _scrollToAvailability() {
    _scrollController.position.ensureVisible(
      _availabilityTileKey.currentContext!.findRenderObject()!,
      alignment: 0,
      duration: const Duration(seconds: 1),
    );
  }

  void _onStateChanged(BuildContext context, SettingsState state) {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final sendFeedbackButtonText = context
        .msg.main.settings.buttons.sendFeedback
        .toUpperCaseIfAndroid(context);
    final logoutButtonText =
        context.msg.main.settings.buttons.logout.toUpperCaseIfAndroid(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
          ),
          child: BlocProvider<SettingsCubit>(
            create: (_) => SettingsCubit(
              context.read<UserDataRefresherCubit>(),
            ),
            child: BlocConsumer<SettingsCubit, SettingsState>(
              listener: _onStateChanged,
              builder: (context, state) {
                final settings = state.settings;
                final isVoipAllowed = state.isVoipAllowed;
                final showTroubleshooting = state.showTroubleshooting;
                final showDnd = state.showDnd;
                final hasIgnoreBatteryOptimizationsPermission =
                    state.hasIgnoreBatteryOptimizationsPermission;
                final showDestinationInSeparateCategory = context.isIOS;
                final cubit = context.watch<SettingsCubit>();

                final availabilityTile = state.systemUser != null
                    ? SettingTile.availability(
                        settings.get<AvailabilitySetting>(),
                        systemUser: state.systemUser!,
                        key: _availabilityTileKey,
                      )
                    : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Header(context.msg.main.settings.title),
                    ),
                    if (!state.isLoading)
                      Expanded(
                        child: ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 8),
                          children: [
                            if (showDnd && state.userAvailabilityType != null)
                              SettingTile.dnd(
                                settings.get<DndSetting>(),
                                userAvailabilityType:
                                    state.userAvailabilityType!,
                                showHelp: _scrollToAvailability,
                              ),
                            if (!showDestinationInSeparateCategory &&
                                availabilityTile != null)
                              availabilityTile,
                            SettingTileCategory.accountInfo(
                              children: [
                                SettingTile.mobileNumber(
                                  setting: settings.get<MobileNumberSetting>(),
                                  isVoipAllowed: isVoipAllowed,
                                ),
                                SettingTile.associatedNumber(
                                  settings.get<BusinessNumberSetting>(),
                                ),
                                if (state.systemUser != null)
                                  SettingTile.username(
                                    state.systemUser!,
                                  ),
                              ],
                            ),
                            if (isVoipAllowed) ...[
                              SettingTileCategory.audio(
                                children: [
                                  SettingTile.usePhoneRingtone(
                                    settings.get<UsePhoneRingtoneSetting>(),
                                  ),
                                ],
                              ),
                              SettingTileCategory.calling(
                                children: [
                                  SettingTile.useVoip(
                                    settings.get<UseVoipSetting>(),
                                  ),
                                  if (context.isIOS)
                                    SettingTile.showCallsInNativeRecents(
                                      settings.get<
                                          ShowCallsInNativeRecentsSetting>(),
                                    ),
                                  SettingTile.ignoreBatteryOptimizations(
                                    hasIgnoreBatteryOptimizationsPermission:
                                        hasIgnoreBatteryOptimizationsPermission,
                                    onChanged: (enabled) =>
                                        cubit.requestBatteryPermission(),
                                  ),
                                ],
                              ),
                              if (showDestinationInSeparateCategory &&
                                  availabilityTile != null)
                                SettingTileCategory.userDestination(
                                  children: [
                                    availabilityTile,
                                  ],
                                ),
                              SettingTileCategory.portalLinks(
                                children: [
                                  SettingLinkTile.calls(),
                                  SettingLinkTile.dialPlan(),
                                  SettingLinkTile.stats(),
                                ],
                              ),
                            ],
                            SettingTileCategory.debug(
                              children: [
                                SettingTile.remoteLogging(
                                  settings.get<RemoteLoggingSetting>(),
                                ),
                              ],
                            ),
                            // Show advanced settings only if allowed.
                            if (isVoipAllowed && showTroubleshooting)
                              SettingTileCategory.advancedSettings(
                                children: [
                                  SettingLinkTile.troubleshooting(),
                                ],
                              ),
                            if (state.buildInfo != null)
                              _BuildInfo(state.buildInfo!),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                              ),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    width: double.infinity,
                                    child: StylizedButton.raised(
                                      colored: true,
                                      onPressed: () =>
                                          _goToFeedbackPage(context),
                                      child: Text(
                                        sendFeedbackButtonText,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: StylizedButton.outline(
                                      colored: true,
                                      onPressed:
                                          context.watch<SettingsCubit>().logout,
                                      child: Text(
                                        logoutButtonText,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BuildInfo extends StatefulWidget {
  final BuildInfo buildInfo;

  const _BuildInfo(this.buildInfo, {Key? key}) : super(key: key);

  @override
  _BuildInfoState createState() => _BuildInfoState();
}

class _BuildInfoState extends State<_BuildInfo> {
  static const _tapCountToShowHiddenSettings = 10;

  int _tapCount = 0;

  void _onTap() {
    _tapCount++;

    if (_tapCount >= 4 && _tapCount <= _tapCountToShowHiddenSettings) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();

      final gainedAccess = _tapCount == _tapCountToShowHiddenSettings;

      if (gainedAccess) {
        context.read<SettingsCubit>().changeSetting(
              const ShowTroubleshootingSettingsSetting(true),
            );
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

        final hasAccessToTroubleshooting =
            state.settings.get<ShowTroubleshootingSettingsSetting>().value;

        const emphasisStyle = TextStyle(fontWeight: FontWeight.bold);

        final showDetails = buildInfo.mergeRequestNumber != null ||
            buildInfo.branchName != null ||
            buildInfo.tag != null;

        return GestureDetector(
          onTap: !hasAccessToTroubleshooting ? _onTap : null,
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: 8,
                bottom: showDetails ? 16 : 8,
              ),
              child: Column(
                children: [
                  Chip(
                    label: Text(
                      '${context.msg.main.settings.list.version} '
                      '${widget.buildInfo.version}',
                    ),
                  ),
                  if (showDetails)
                    Text.rich(
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

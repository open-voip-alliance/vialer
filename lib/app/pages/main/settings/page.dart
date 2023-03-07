import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../domain/user/info/build_info.dart';
import '../../../../domain/user/launch_privacy_policy.dart';
import '../../../../domain/user/settings/app_setting.dart';
import '../../../../domain/user/settings/call_setting.dart';
import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../routes.dart';
import '../../../util/conditional_capitalization.dart';
import '../../../widgets/stylized_button.dart';
import '../business_availability/temporary_redirect/setting_tile.dart';
import '../util/stylized_snack_bar.dart';
import '../widgets/header.dart';
import '../widgets/user_data_refresher/cubit.dart';
import 'cubit.dart';
import 'widgets/tile/availability.dart';
import 'widgets/tile/category/account_info.dart';
import 'widgets/tile/category/advanced_settings.dart';
import 'widgets/tile/category/audio.dart';
import 'widgets/tile/category/calling.dart';
import 'widgets/tile/category/debug.dart';
import 'widgets/tile/category/portal_links.dart';
import 'widgets/tile/category/temporary_redirect.dart';
import 'widgets/tile/dnd.dart';
import 'widgets/tile/ignore_battery_optimizations.dart';
import 'widgets/tile/link/calls.dart';
import 'widgets/tile/link/dial_plan.dart';
import 'widgets/tile/link/opening_hours.dart';
import 'widgets/tile/link/stats.dart';
import 'widgets/tile/link/troubleshooting.dart';
import 'widgets/tile/mobile_number.dart';
import 'widgets/tile/outgoing_number.dart';
import 'widgets/tile/remote_logging.dart';
import 'widgets/tile/show_calls_in_native_recents.dart';
import 'widgets/tile/show_client_calls.dart';
import 'widgets/tile/use_mobile_number_as_fallback.dart';
import 'widgets/tile/use_phone_ringtone.dart';
import 'widgets/tile/use_voip.dart';
import 'widgets/tile/username.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();

  static const keys = _Keys();
}

class _SettingsPageState extends State<SettingsPage> {
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
        icon: const FaIcon(FontAwesomeIcons.check),
        label: Text(context.msg.main.settings.feedback.snackBar),
      );
    }

    context.read<SettingsCubit>().refresh();
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
    final privacyPolicyText =
        context.msg.main.settings.privacyPolicy.toUpperCaseIfAndroid(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Header(context.msg.main.settings.title),
              ),
              BlocProvider<SettingsCubit>(
                create: (_) => SettingsCubit(
                  context.read<UserDataRefresherCubit>(),
                ),
                child: BlocConsumer<SettingsCubit, SettingsState>(
                  listener: _onStateChanged,
                  builder: (context, state) {
                    final user = state.user;
                    final isVoipAllowed = state.isVoipAllowed;
                    final showTroubleshooting = state.showTroubleshooting;
                    final showDnd = state.showDnd;
                    final hasIgnoreOptimizationsPermission =
                        state.hasIgnoreBatteryOptimizationsPermission;
                    final userNumber = state.userNumber;
                    final destinations = state.availableDestinations;
                    final cubit = context.watch<SettingsCubit>();

                    final useVoip = user.settings.get(CallSetting.useVoip);
                    final canViewMobileFallback =
                        user.permissions.canViewMobileNumberFallbackStatus;

                    return Expanded(
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 8),
                        children: [
                          if (showDnd) DndTile(user),
                          AvailabilityTile(
                            user: user,
                            userNumber: userNumber,
                            destinations: destinations,
                          ),
                          AccountInfoCategory(
                            children: [
                              MobileNumberTile(user),
                              OutgoingNumberTile(user),
                              UsernameTile(user),
                            ],
                          ),
                          if (isVoipAllowed)
                            AudioCategory(
                              children: [
                                UsePhoneRingtoneTile(user),
                              ],
                            ),
                          CallingCategory(
                            children: [
                              if (isVoipAllowed) UseVoipTile(user),
                              if (useVoip &&
                                  canViewMobileFallback &&
                                  isVoipAllowed)
                                UseMobileNumberAsFallbackTile(user),
                              if (context.isIOS && isVoipAllowed)
                                ShowCallsInNativeRecentsTile(user),
                              if (context.isAndroid)
                                IgnoreBatteryOptimizationsTile(
                                  hasIgnoreBatteryOptimizationsPermission:
                                      hasIgnoreOptimizationsPermission,
                                  onChanged: (enabled) =>
                                      cubit.requestBatteryPermission(),
                                ),
                              ShowClientCallsTile(user),
                            ],
                          ),
                          if (user.permissions.canChangeTemporaryRedirect)
                            const TemporaryRedirectCategory(
                              children: [
                                TemporaryRedirectSettingTile(),
                              ],
                            ),
                          PortalLinksCategory(
                            children: [
                              const CallsLinkTile(),
                              const DialPlanLinkTile(),
                              if (cubit.shouldShowOpeningHoursBasic() &&
                                  user.client.openingHours.isNotEmpty)
                                OpeningHoursLinkTile(user),
                              const StatsLinkTile(),
                            ],
                          ),
                          DebugCategory(
                            children: [
                              RemoteLoggingTile(user),
                            ],
                          ),
                          // Show advanced settings only if allowed.
                          if (isVoipAllowed && showTroubleshooting)
                            const AdvancedSettingsCategory(
                              children: [
                                TroubleshootingLinkTile(),
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
                                    onPressed: () => _goToFeedbackPage(context),
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
                                TextButton(
                                  onPressed: () => LaunchPrivacyPolicy()(),
                                  child: Text(privacyPolicyText),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
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

class _Keys {
  const _Keys();

  final mobileNumber = const Key('mobileNumberSetting');
}

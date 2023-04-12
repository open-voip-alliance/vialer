import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/user/settings/call_setting.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../cubit.dart';
import '../widgets/tile/build_info.dart';
import '../widgets/tile/category/advanced_settings.dart';
import '../widgets/tile/category/audio.dart';
import '../widgets/tile/category/calling.dart';
import '../widgets/tile/category/debug.dart';
import '../widgets/tile/category/recents.dart';
import '../widgets/tile/enable_dialer_contact_search.dart';
import '../widgets/tile/feedback.dart';
import '../widgets/tile/ignore_battery_optimizations.dart';
import '../widgets/tile/link/troubleshooting.dart';
import '../widgets/tile/privacy_policy.dart';
import '../widgets/tile/remote_logging.dart';
import '../widgets/tile/show_calls_in_native_recents.dart';
import '../widgets/tile/show_client_calls.dart';
import '../widgets/tile/use_mobile_number_as_fallback.dart';
import '../widgets/tile/use_phone_ringtone.dart';
import '../widgets/tile/use_voip.dart';
import 'widget.dart';

class AppPreferencesSubPage extends StatelessWidget {
  const AppPreferencesSubPage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final user = state.user;
        final useVoip = user.settings.get(CallSetting.useVoip);
        final canViewMobileFallback =
            user.permissions.canViewMobileNumberFallbackStatus;
        final hasIgnoreOptimizationsPermission =
            state.hasIgnoreBatteryOptimizationsPermission;
        final showTroubleshooting = state.showTroubleshooting;
        final cubit = context.watch<SettingsCubit>();

        return SettingsSubPage(
          cubit: cubit,
          title: context.msg.main.settings.subPage.appPreferences.title,
          child: (state) {
            return ListView(
              children: [
                CallingCategory(
                  children: [
                    if (user.isAllowedVoipCalling) UseVoipTile(user),
                    if (useVoip && canViewMobileFallback)
                      UseMobileNumberAsFallbackTile(user),
                    if (context.isIOS && user.isAllowedVoipCalling)
                      ShowCallsInNativeRecentsTile(user),
                    if (context.isAndroid)
                      IgnoreBatteryOptimizationsTile(
                        hasIgnoreBatteryOptimizationsPermission:
                            hasIgnoreOptimizationsPermission,
                        onChanged: (enabled) =>
                            cubit.requestBatteryPermission(),
                      ),
                    if (context.isIOS) EnableT9ContactSearch(user),
                  ],
                ),
                RecentsCategory(
                  children: [
                    ShowClientCallsTile(user),
                  ],
                ),
                if (user.isAllowedVoipCalling)
                  AudioCategory(
                    children: [
                      UsePhoneRingtoneTile(user),
                    ],
                  ),
                DebugCategory(
                  children: [
                    RemoteLoggingTile(user),
                  ],
                ),
                if (user.isAllowedVoipCalling && showTroubleshooting)
                  const AdvancedSettingsCategory(
                    children: [
                      TroubleshootingLinkTile(),
                    ],
                  ),
                const FeedbackTile(),
                if (state.buildInfo != null) BuildInfoTile(state.buildInfo!),
                const PrivacyPolicyTile(),
              ],
            );
          },
        );
      },
    );
  }
}

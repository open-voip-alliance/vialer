import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/settings/pages/about_the_app.dart';
import 'package:vialer/presentation/features/settings/pages/system/system.dart';

import '../../../../../data/repositories/env.dart';
import '../../../resources/localizations.dart';
import '../../../util/stylized_snack_bar.dart';
import '../controllers/cubit.dart';
import '../widgets/availability/widget.dart';
import '../widgets/container.dart';
import '../widgets/header/widget.dart';
import '../widgets/rate_limited_snackbar_label.dart';
import '../widgets/tile/link/sub_page.dart';
import 'app_preferences.dart';
import 'client.dart';
import 'user.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({required this.navigatorKey, super.key});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<StatefulWidget> createState() => _SettingsPageState();

  static const keys = _Keys();
}

class _SettingsPageState extends State<SettingsPage> {
  // We want to be able to show snackbars on only the settings page, so we're
  // going to create a [ScaffoldMessenger] with this key, then show snackbars
  // based on it.
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void _onStateChanged(BuildContext context, SettingsState state) {
    FocusScope.of(context).unfocus();
    _showSnackbarWhenRateLimited(state);
  }

  void _showSnackbarWhenRateLimited(SettingsState state) {
    if (!state.isRateLimited || _scaffoldMessengerKey.currentState == null) {
      return;
    }

    showSnackBar(
      context,
      duration: SettingsCubit.rateLimitDuration,
      icon: const FaIcon(FontAwesomeIcons.triangleExclamation),
      label: RateLimitedSnackbarLabel(
        expiresAt: DateTime.now().add(SettingsCubit.rateLimitDuration),
      ),
      scaffoldMessengerState: _scaffoldMessengerKey.currentState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageContainer(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      navigatorKey: widget.navigatorKey,
      child: BlocConsumer<SettingsCubit, SettingsState>(
        listener: _onStateChanged,
        // We're not going to listen when there are new rate limited states
        // being added while already rate limited. The widget will still build
        // though.
        listenWhen: (previous, current) =>
            !previous.isRateLimited || !current.isRateLimited,
        builder: (context, state) {
          final user = state.user;
          final cubit = context.watch<SettingsCubit>();

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Header(user: state.user),
                          const AvailabilitySwitcher(),
                          const Divider(),
                          SubPageLinkTile(
                            title: context
                                .msg.main.settings.subPage.appPreferences.title,
                            icon: FontAwesomeIcons.solidMobileNotch,
                            cubit: cubit,
                            pageBuilder: (_) => const AppPreferencesSubPage(),
                          ),
                          SubPageLinkTile(
                            title: context.msg.main.settings.subPage.user
                                .title(user.fullName),
                            icon: FontAwesomeIcons.circleUser,
                            cubit: cubit,
                            pageBuilder: (_) => const UserSubPage(),
                          ),
                          if (user.canViewClientSubPage)
                            SubPageLinkTile(
                              title: context.msg.main.settings.subPage.client
                                  .title(user.client.name),
                              icon: FontAwesomeIcons.building,
                              cubit: cubit,
                              pageBuilder: (_) => const ClientSubPage(),
                            ),
                          SubPageLinkTile(
                            title: context
                                .msg.main.settings.subPage.aboutTheApp.title,
                            icon: FontAwesomeIcons.circleInfo,
                            cubit: cubit,
                            pageBuilder: (_) => const AboutTheAppSubPage(),
                          ),
                          if (!isProduction)
                            SubPageLinkTile(
                              title: context
                                  .msg
                                  .main
                                  .settings
                                  .list
                                  .advancedSettings
                                  .troubleshooting
                                  .system
                                  .title,
                              icon: FontAwesomeIcons.roadBarrier,
                              cubit: cubit,
                              pageBuilder: (_) => const SystemSubPage(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Keys {
  const _Keys();

  Key get mobileNumber => const Key('mobileNumberSetting');
}

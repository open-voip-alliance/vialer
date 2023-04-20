import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../resources/localizations.dart';
import '../util/stylized_snack_bar.dart';
import '../widgets/nested_navigator.dart';
import 'cubit.dart';
import 'header/widget.dart';
import 'sub_page/app_preferences.dart';
import 'sub_page/client.dart';
import 'sub_page/user.dart';
import 'widgets/rate_limited_snackbar_label.dart';
import 'widgets/tile/availability.dart';
import 'widgets/tile/dnd.dart';
import 'widgets/tile/link/sub_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: NestedNavigator(
        routes: {
          'root': (context, _) {
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
                      BlocProvider<SettingsCubit>(
                        create: (_) => SettingsCubit(),
                        child: BlocConsumer<SettingsCubit, SettingsState>(
                          listener: _onStateChanged,
                          // We're not going to listen when there are new
                          // rate limited states being added while already rate
                          // limited. The widget will still build though.
                          listenWhen: (previous, current) =>
                              !previous.isRateLimited || !current.isRateLimited,
                          builder: (context, state) {
                            final user = state.user;
                            final showDnd = state.showDnd;
                            final userNumber = state.userNumber;
                            final destinations = state.availableDestinations;
                            final cubit = context.watch<SettingsCubit>();

                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Header(user: state.user),
                                            if (showDnd)
                                              DndTile(
                                                user,
                                                enabled: state
                                                    .shouldAllowRemoteSettings,
                                              ),
                                            AvailabilityTile(
                                              user: user,
                                              userNumber: userNumber,
                                              destinations: destinations,
                                              enabled: state
                                                  .shouldAllowRemoteSettings,
                                            ),
                                            SubPageLinkTile(
                                              title: context.msg.main.settings
                                                  .subPage.appPreferences.title,
                                              icon: FontAwesomeIcons
                                                  .solidMobileNotch,
                                              cubit: cubit,
                                              pageBuilder: (_) =>
                                                  const AppPreferencesSubPage(),
                                            ),
                                            SubPageLinkTile(
                                              title: context.msg.main.settings
                                                  .subPage.user
                                                  .title(user.fullName),
                                              icon: FontAwesomeIcons.circleUser,
                                              cubit: cubit,
                                              pageBuilder: (_) =>
                                                  const UserSubPage(),
                                            ),
                                            if (user.canViewClientSubPage)
                                              SubPageLinkTile(
                                                title: context.msg.main.settings
                                                    .subPage.client
                                                    .title(user.client.name),
                                                icon: FontAwesomeIcons.building,
                                                cubit: cubit,
                                                pageBuilder: (_) =>
                                                    const ClientSubPage(),
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        },
      ),
    );
  }
}

class _Keys {
  const _Keys();

  final mobileNumber = const Key('mobileNumberSetting');
}

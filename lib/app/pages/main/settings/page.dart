import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../util/stylized_snack_bar.dart';
import '../widgets/nested_navigator.dart';
import 'cubit.dart';
import 'header/widget.dart';
import 'sub_page/app_preferences.dart';
import 'sub_page/client.dart';
import 'sub_page/user.dart';
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
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void _onStateChanged(BuildContext context, SettingsState state) {
    FocusScope.of(context).unfocus();

    if (!state.isRateLimited || _scaffoldMessengerKey.currentState == null) {
      return;
    }

    showSnackBar(
      context,
      duration: SettingsCubit.rateLimitDuration,
      icon: const FaIcon(FontAwesomeIcons.triangleExclamation),
      label: Text(
        context.msg.rateLimiting.snackbar.message(
          context.brand.appName,
          SettingsCubit.rateLimitDuration.inSeconds.toString(),
        ),
      ),
      state: _scaffoldMessengerKey.currentState,
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
                                                enabled:
                                                    !state.isApplyingChanges,
                                              ),
                                            AvailabilityTile(
                                              user: user,
                                              userNumber: userNumber,
                                              destinations: destinations,
                                              enabled: !state.isApplyingChanges,
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

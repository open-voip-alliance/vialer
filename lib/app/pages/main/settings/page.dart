import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../resources/localizations.dart';
import 'cubit.dart';
import 'footer/widget.dart';
import 'header/widget.dart';
import 'sub_page/client.dart';
import 'sub_page/phone_preferences.dart';
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
  void _onStateChanged(BuildContext context, SettingsState state) {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
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
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Header(user: state.user),
                                    if (showDnd) DndTile(user),
                                    AvailabilityTile(
                                      user: user,
                                      userNumber: userNumber,
                                      destinations: destinations,
                                      enabled: !state.isUpdatingRemote,
                                    ),
                                    SubPageLinkTile(
                                      title: context.msg.main.settings.subPage
                                          .phonePreferences.title,
                                      icon: FontAwesomeIcons.solidMobileNotch,
                                      cubit: cubit,
                                      pageBuilder: (_) =>
                                          const PhonePreferencesSubPage(),
                                    ),
                                    SubPageLinkTile(
                                      title: context
                                          .msg.main.settings.subPage.user
                                          .title(user.fullName),
                                      icon: FontAwesomeIcons.circleUser,
                                      cubit: cubit,
                                      pageBuilder: (_) => const UserSubPage(),
                                    ),
                                    if (user.canViewClientSubPage)
                                      SubPageLinkTile(
                                        title: context
                                            .msg.main.settings.subPage.client
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
                            Footer(buildInfo: state.buildInfo),
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
  }
}

class _Keys {
  const _Keys();

  final mobileNumber = const Key('mobileNumberSetting');
}

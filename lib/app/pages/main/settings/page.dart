import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../domain/user/info/build_info.dart';
import '../../../../domain/user/launch_privacy_policy.dart';
import '../../../../domain/user/settings/app_setting.dart';
import '../../../resources/localizations.dart';
import '../../../routes.dart';
import '../../../util/conditional_capitalization.dart';
import '../../../widgets/stylized_button.dart';
import '../util/stylized_snack_bar.dart';
import '../widgets/header.dart';
import '../widgets/user_data_refresher/cubit.dart';
import 'cubit.dart';
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
                    final showDnd = state.showDnd;
                    final userNumber = state.userNumber;
                    final destinations = state.availableDestinations;
                    final cubit = context.watch<SettingsCubit>();

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                if (showDnd) DndTile(user),
                                AvailabilityTile(
                                  user: user,
                                  userNumber: userNumber,
                                  destinations: destinations,
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
                                  title: context.msg.main.settings.subPage.user
                                      .title(user.fullName),
                                  icon: FontAwesomeIcons.circleUser,
                                  cubit: cubit,
                                  pageBuilder: (_) => const UserSubPage(),
                                ),
                                SubPageLinkTile(
                                  title: context
                                      .msg.main.settings.subPage.client
                                      .title(user.client.name),
                                  icon: FontAwesomeIcons.building,
                                  cubit: cubit,
                                  pageBuilder: (_) => const ClientSubPage(),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
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
                                        onPressed: context
                                            .watch<SettingsCubit>()
                                            .logout,
                                        child: Text(
                                          logoutButtonText,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextButton(
                                      onPressed: () => LaunchPrivacyPolicy()(),
                                      child: Text(privacyPolicyText),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ],
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

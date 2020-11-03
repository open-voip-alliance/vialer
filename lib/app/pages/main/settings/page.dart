import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../entities/setting_route_info.dart';
import '../../../entities/setting_route.dart';

import '../../../../domain/entities/setting.dart';
import '../../../../domain/entities/build_info.dart';

import '../../../routes.dart';
import '../../../widgets/stylized_button.dart';
import '../widgets/header.dart';
import 'widgets/settings_list_view.dart';

import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';

import '../../../util/conditional_capitalization.dart';
import '../util/stylized_snack_bar.dart';

import 'sub_page.dart';

import 'cubit.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key key}) : super(key: key);

  Future<void> _goToFeedbackPage(BuildContext context) async {
    final sent = await Navigator.pushNamed(
          context,
          Routes.feedback,
        ) as bool ??
        false;

    if (sent) {
      showSnackBar(
        context,
        icon: Icon(VialerSans.check),
        label: Text(context.msg.main.settings.feedback.snackBar),
      );
    }
  }

  void _onStateChanged(BuildContext context, SettingsState state) {
    if (state is LoggedOut) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.onboarding,
        (r) => false,
      );
    }
  }

  void _goToSubPage(
    BuildContext context,
    SettingsCubit cubit,
    SettingRouteInfo routeInfo,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return SettingsSubPage(
          cubit: cubit,
          routeInfo: routeInfo,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sendFeedbackButtonText = context
        .msg.main.settings.buttons.sendFeedback
        .toUpperCaseIfAndroid(context);
    final logoutButtonText =
        context.msg.main.settings.buttons.logout.toUpperCaseIfAndroid(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
          ),
          child: BlocProvider<SettingsCubit>(
            create: (_) => SettingsCubit(),
            child: BlocConsumer<SettingsCubit, SettingsState>(
              listener: _onStateChanged,
              builder: (context, state) {
                final cubit = context.bloc<SettingsCubit>();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Header(context.msg.main.settings.title),
                    ),
                    Expanded(
                      child: SettingsListView(
                        route: SettingRoute.main,
                        settings: state.settings,
                        onSettingChanged: cubit.changeSetting,
                        onRouteLinkTapped: (info) =>
                            _goToSubPage(context, cubit, info),
                        children: [
                          if (state.buildInfo != null)
                            _BuildInfo(state.buildInfo)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
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
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: StylizedButton.outline(
                              colored: true,
                              onPressed: context.bloc<SettingsCubit>().logout,
                              child: Text(
                                logoutButtonText,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
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

  const _BuildInfo(this.buildInfo, {Key key}) : super(key: key);

  @override
  _BuildInfoState createState() => _BuildInfoState();
}

class _BuildInfoState extends State<_BuildInfo> {
  static const _tapCountToShowHiddenSettings = 10;

  int _tapCount = 0;

  void _onTap() {
    _tapCount++;

    if (_tapCount >= 4 && _tapCount <= _tapCountToShowHiddenSettings) {
      Scaffold.of(context).removeCurrentSnackBar();

      final gainedAccess = _tapCount == _tapCountToShowHiddenSettings;

      if (gainedAccess) {
        context.bloc<SettingsCubit>().changeSetting(
              ShowTroubleshootingSettingsSetting(true),
            );
      }

      Scaffold.of(context).showSnackBar(
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
        final hasAccessToTroubleshooting =
            state.settings.get<ShowTroubleshootingSettingsSetting>()?.value ??
                false;

        return GestureDetector(
          onTap: !hasAccessToTroubleshooting ? _onTap : null,
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Chip(
                label: Text(
                  '${context.msg.main.settings.list.version} '
                  '${widget.buildInfo.version}',
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

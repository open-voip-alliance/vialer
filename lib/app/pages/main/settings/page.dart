import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartx/dartx.dart';

import '../../../../domain/entities/build_info.dart';
import '../../../../domain/entities/setting.dart';

import '../../../routes.dart';
import '../../../widgets/stylized_button.dart';
import '../widgets/header.dart';
import 'widgets/tile.dart';

import '../../../resources/localizations.dart';

import '../../../mappers/setting.dart';

import '../../../util/conditional_capitalization.dart';
import '../util/stylized_snack_bar.dart';

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
        text: context.msg.main.settings.feedback.snackBar,
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
          padding: EdgeInsets.only(
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
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Header(context.msg.main.settings.title),
                    ),
                    Expanded(
                      child: _Content(
                        settings: cubit.state.settings,
                        buildInfo: cubit.state.buildInfo,
                        onSettingChanged: cubit.changeSetting,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 48),
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

class _Content extends StatelessWidget {
  final List<Setting> settings;
  final BuildInfo buildInfo;
  final ValueChanged<Setting> onSettingChanged;

  _Content({
    Key key,
    @required this.settings,
    @required this.buildInfo,
    @required this.onSettingChanged,
  })  : assert(settings != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Iterable<Setting> settings = this.settings;

    // Don't show the show dialer and show survey setting (for now)
    settings = settings.where(
      (setting) =>
          setting is! ShowDialerConfirmPopupSetting &&
          setting is! ShowSurveyDialogSetting,
    );

    final categories = settings
        .map(
          (s) => s.toInfo(context).category,
        )
        .distinct();

    final settingsByCategory = Map.fromEntries(
      categories.map(
        (category) => MapEntry(
          category,
          settings
              .where((s) => s.toInfo(context).category == category)
              .toList(growable: false),
        ),
      ),
    );

    final widgets = <Widget>[];
    settingsByCategory.forEach((category, settings) {
      widgets.add(
        SettingTileCategory(
          category: category,
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: settings.map((setting) {
            return SettingTile(
              setting,
              onChanged: onSettingChanged,
            );
          }).toList(growable: false),
        ),
      );
    });

    if (buildInfo != null) {
      widgets.add(
        Chip(
          label: Text(
            '${context.msg.main.settings.list.version}'
            ' ${buildInfo.version}',
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.only(
        top: 8,
      ),
      children: widgets,
    );
  }
}

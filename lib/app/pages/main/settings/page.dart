import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartx/dartx.dart';

import '../../../entities/category.dart';

import '../../../../domain/entities/build_info.dart';
import '../../../../domain/entities/setting.dart';

import '../../../routes.dart';
import '../../../widgets/stylized_button.dart';
import '../widgets/header.dart';
import 'widgets/tile.dart';

import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';

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
                      child: _Content(
                        settings: cubit.state.settings,
                        buildInfo: cubit.state.buildInfo,
                        onSettingChanged: cubit.changeSetting,
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
    // Don't show the show dialer and show survey setting (for now).
    final settings = this.settings.where(
          (setting) =>
              setting is! ShowDialerConfirmPopupSetting &&
              setting is! ShowSurveyDialogSetting,
        );

    return ListView(
      padding: const EdgeInsets.only(
        top: 8,
      ),
      children: [
        ...settings
            .map((s) => s.toInfo(context).category)
            .distinct()
            .sortedBy((c) => c.toInfo(context).order)
            .map(
              (category) => MapEntry(
                category,
                settings
                    .where((s) => s.toInfo(context).category == category)
                    .sortedBy((s) => s.toInfo(context).order),
              ),
            )
            .mapEntries(
              (category, settings) => SettingTileCategory(
                category: category,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(top: 16),
                children: [
                  ...settings.map(
                    (setting) => SettingTile(
                      setting,
                      onChanged: onSettingChanged,
                    ),
                  ),
                ],
              ),
            ),
        if (buildInfo != null)
          Chip(
            label: Text(
              '${context.msg.main.settings.list.version}'
              ' ${buildInfo.version}',
            ),
          ),
      ],
    );
  }
}

extension _MapEntries<K, V> on Iterable<MapEntry<K, V>> {
  Iterable<T> mapEntries<T>(T Function(K key, V value) mapper) =>
      map((e) => mapper(e.key, e.value));
}

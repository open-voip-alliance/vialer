import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/setting.dart';

import '../../../widgets/stylized_button.dart';
import '../widgets/header.dart';
import 'widgets/tile.dart';

import '../../../resources/localizations.dart';

import '../../../mappers/setting.dart';

import '../../../util/conditional_capitalization.dart';

import 'controller.dart';

class SettingsPage extends View {
  SettingsPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ViewState<SettingsPage, SettingsController> {
  _SettingsPageState() : super(SettingsController());

  List<Widget> get settingsList {
    Iterable<Setting> settings = controller.settings;
    if (settings == null || settings.isEmpty) {
      return [];
    }

    // Don't show the show dialer setting (for now)
    settings = settings.where(
      (setting) => setting is! ShowDialerConfirmPopupSetting,
    );

    final categories = settings
        .map(
          (s) => s.toInfo(context).category,
        )
        .toSet();

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
              onChanged: (value) => controller.changeSetting(
                setting.copyWith(value: value),
              ),
            );
          }).toList(growable: false),
        ),
      );
    });

    if (controller.buildInfo != null) {
      widgets.add(
        Chip(
          label: Text(
            '${context.msg.main.settings.list.version}'
            ' ${controller.buildInfo.version}',
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget buildPage() {
    final sendFeedbackButtonText = context
        .msg.main.settings.buttons.sendFeedback
        .toUpperCaseIfAndroid(context);
    final logoutButtonText =
        context.msg.main.settings.buttons.logout.toUpperCaseIfAndroid(context);

    return Scaffold(
      key: globalKey,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Header(context.msg.main.settings.title),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    top: 8,
                  ),
                  children: settingsList,
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
                        onPressed: controller.goToFeedbackPage,
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
                        onPressed: controller.logout,
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
          ),
        ),
      ),
    );
  }
}

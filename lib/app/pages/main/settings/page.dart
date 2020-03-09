import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/storage.dart';

import '../widgets/header.dart';
import 'controller.dart';
import 'widgets/tile.dart';
import '../widgets/colored_button.dart';

import '../../../resources/theme.dart';
import '../../../resources/localizations.dart';

import '../../../mappers/setting.dart';

class SettingsPage extends View {
  final SettingRepository _settingsRepository;
  final StorageRepository _storageRepository;

  SettingsPage(
    this._settingsRepository,
    this._storageRepository, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState(
        _settingsRepository,
        _storageRepository,
      );
}

class _SettingsPageState extends ViewState<SettingsPage, SettingsController> {
  _SettingsPageState(
    SettingRepository settingRepository,
    StorageRepository storageRepository,
  ) : super(SettingsController(settingRepository, storageRepository));

  List<Widget> get settingsList {
    final settings = controller.settings;
    if (settings == null || settings.isEmpty) {
      return [];
    }

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

    return widgets;
  }

  @override
  Widget buildPage() {
    var sendFeedbackButtonText = context.msg.main.settings.buttons.sendFeedback;
    var logoutButtonText = context.msg.main.settings.buttons.logout;
    if (!context.isIOS) {
      logoutButtonText = logoutButtonText.toUpperCase();
      sendFeedbackButtonText = sendFeedbackButtonText.toUpperCase();
    }

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
                padding: EdgeInsets.symmetric(horizontal: 16).copyWith(
                  bottom: 24,
                ),
                child: Header(context.msg.main.settings.title),
              ),
              Expanded(
                child: ListView(
                  children: settingsList,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: ColoredButton.filled(
                        onPressed: () {},
                        child: Text(sendFeedbackButtonText),
                      ),
                    ),
                    SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: ColoredButton.outline(
                        onPressed: controller.logout,
                        child: Text(logoutButtonText),
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

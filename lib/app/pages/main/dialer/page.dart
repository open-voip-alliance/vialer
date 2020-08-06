import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:provider/provider.dart';

import '../../../resources/theme.dart';
import '../../../resources/localizations.dart';

import '../../../widgets/transparent_status_bar.dart';
import 'widgets/key_input.dart';
import 'widgets/keypad.dart';
import '../widgets/conditional_placeholder.dart';
import '../../../widgets/stylized_button.dart';

import '../../../../domain/entities/brand.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/repositories/permission.dart';
import '../../../../domain/repositories/storage.dart';
import '../../../../domain/repositories/logging.dart';
import '../../../../domain/repositories/setting.dart';

import '../../../util/conditional_capitalization.dart';

import 'controller.dart';

class DialerPage extends View {
  final CallRepository _callRepository;
  final SettingRepository _settingRepository;
  final LoggingRepository _loggingRepository;
  final PermissionRepository _permissionRepository;
  final StorageRepository _storageRepository;

  /// If destination is not null, call [destination] on open.
  final String destination;

  DialerPage(
    this._callRepository,
    this._settingRepository,
    this._loggingRepository,
    this._permissionRepository,
    this._storageRepository, {
    this.destination,
  });

  @override
  State<StatefulWidget> createState() => _DialerPageState(
        _callRepository,
        _settingRepository,
        _loggingRepository,
        _permissionRepository,
        _storageRepository,
        destination,
      );
}

class _DialerPageState extends ViewState<DialerPage, DialerController> {
  _DialerPageState(
    CallRepository callRepository,
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
    PermissionRepository permissionRepository,
    StorageRepository storageRepository,
    String destination,
  ) : super(
          DialerController(
            callRepository,
            settingRepository,
            loggingRepository,
            permissionRepository,
            storageRepository,
            destination,
          ),
        );

  @override
  Widget buildPage() {
    return Scaffold(
      key: globalKey,
      body: TransparentStatusBar(
        brightness: Brightness.dark,
        child: ConditionalPlaceholder(
          showPlaceholder: !controller.canCall,
          placeholder: Warning(
            title: Text(context.msg.main.dialer.noPermission.title),
            description: !controller.showSettingsDirections
                ? Text(context.msg.main.dialer.noPermission
                    .description(Provider.of<Brand>(context).appName))
                : Text(context.msg.main.dialer.noPermission
                    .permanentDescription(Provider.of<Brand>(context).appName)),
            icon: Icon(VialerSans.missedCall),
            children: !controller.showSettingsDirections
                ? <Widget>[
                    SizedBox(height: 40),
                    StylizedButton.raised(
                      colored: true,
                      onPressed: controller.askPermission,
                      child: Text(
                        context.msg.main.dialer.noPermission.button
                            .toUpperCaseIfAndroid(context),
                      ),
                    ),
                  ]
                : <Widget>[],
          ),
          child: Column(
            children: <Widget>[
              Material(
                elevation: context.isIOS ? 0 : 8,
                child: SafeArea(
                  child: SizedBox(
                    height: 96,
                    child: Center(
                      child: KeyInput(
                        controller: controller.keypadController,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Keypad(
                      controller: controller.keypadController,
                      onCallButtonPressed: controller.startCall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

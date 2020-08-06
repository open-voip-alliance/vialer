import 'package:flutter/material.dart' hide Step;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/onboarding/step.dart';
import '../../../../domain/entities/brand.dart';

import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/auth.dart';
import '../../../../domain/repositories/logging.dart';

import '../../../resources/theme.dart';
import '../../../resources/localizations.dart';

import '../../../widgets/stylized_button.dart';
import '../widgets/stylized_text_field.dart';
import '../widgets/error.dart';

import '../../../util/conditional_capitalization.dart';

import 'controller.dart';

class PasswordPage extends View {
  final AuthRepository _authRepository;
  final SettingRepository _settingRepository;
  final LoggingRepository _loggingRepository;

  final Brand _brand;
  final VoidCallback forward;
  final void Function(Step) addStep;

  PasswordPage(
    this._authRepository,
    this._settingRepository,
    this._loggingRepository,
    this._brand,
    this.forward,
    this.addStep, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PasswordPageState(
        _authRepository,
        _settingRepository,
        _loggingRepository,
        _brand,
        forward,
        addStep,
      );
}

class _PasswordPageState extends ViewState<PasswordPage, PasswordController>
    with TickerProviderStateMixin {
  _PasswordPageState(
    AuthRepository authRepository,
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
    Brand brand,
    VoidCallback forward,
    void Function(Step) addStep,
  ) : super(
          PasswordController(
            authRepository,
            settingRepository,
            loggingRepository,
            forward,
          ),
        );

  @override
  Widget buildPage() {
    return Padding(
      key: globalKey,
      padding: Provider.of<EdgeInsets>(context).copyWith(top: 32),
      child: Column(
        children: <Widget>[
          Text(
            context.msg.onboarding.password.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          ErrorAlert(
            visible: controller.passwordChangeFailed,
            child: Text(context.msg.onboarding.password.error),
          ),
          StylizedTextField(
            controller: controller.passwordController,
            prefixIcon: VialerSans.lockOn,
            obscureText: true,
            hasError: controller.passwordChangeFailed,
          ),
          SizedBox(height: 16),
          Text(
            context.msg.onboarding.password.requirements,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: StylizedButton.raised(
              onPressed: controller.changePassword,
              child: Text(
                context.msg.onboarding.password.button
                    .toUpperCaseIfAndroid(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

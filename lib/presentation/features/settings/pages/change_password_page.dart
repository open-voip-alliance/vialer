import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:vialer/presentation/features/settings/controllers/change_password_state.dart';
import 'package:vialer/presentation/features/settings/widgets/settings_button.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/messages.i18n.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:vialer/presentation/shared/widgets/error.dart';
import 'package:vialer/presentation/shared/widgets/stylized_text_field.dart';

import '../controllers/cubit.dart';
import 'settings_subpage.dart';

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SettingsSubPage(
          cubit: context.watch<SettingsCubit>(),
          title: context.strings.title,
          child: (state) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: BlocProvider(
                      create: (_) => ChangePasswordCubit(),
                      child: _ChangePasswordListView(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ChangePasswordListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChangePasswordListViewState();
}

class _ChangePasswordListViewState extends State<_ChangePasswordListView> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          context.strings.apiTokenChangeNotice,
          style: const TextStyle(fontSize: 16),
        ),
        const Gap(16),
        _FieldHeader(context.strings.current.title),
        const Gap(8),
        _PasswordInput(oldPasswordController),
        BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
          builder: (context, state) {
            return ErrorAlert(
              visible: state.errorOldPassword.isNotEmpty,
              inline: true,
              message: state.errorOldPassword,
            );
          },
        ),
        const Gap(8),
        Text(context.strings.current.description),
        const Gap(16),
        _FieldHeader(context.strings.newpassword.title),
        const Gap(8),
        _PasswordInput(
          newPasswordController,
          newPasswordHint: true,
        ),
        BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
          builder: (context, state) {
            return ErrorAlert(
              visible: state.errorNewPassword.isNotEmpty,
              inline: true,
              message: state.errorNewPassword,
            );
          },
        ),
        const Gap(8),
        Text(context.strings.newpassword.description),
        const Gap(32),
        SettingsButton(
          text: context.strings.actions.save,
          onPressed: saveButtonHandler,
        ),
        const Gap(16),
        SettingsButton(
          text: context.msg.generic.button.cancel,
          solid: false,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void saveButtonHandler() async {
    if (await context.read<ChangePasswordCubit>().savePasswordHandler(
          context: context,
          oldPassword: oldPasswordController.text,
          newPassword: newPasswordController.text,
        )) {
      unawaited(
        showDialog<void>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(context.strings.changed),
              actions: [
                TextButton(
                  onPressed: () async {
                    await context.read<ChangePasswordCubit>().logout();
                  },
                  child: Text(context.msg.generic.button.close),
                ),
              ],
              content: Text(context.strings.loginAgain),
            );
          },
        ),
      );
    }
  }
}

class _FieldHeader extends StatelessWidget {
  const _FieldHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final bool newPasswordHint;

  const _PasswordInput(
    this.controller, {
    this.newPasswordHint = false,
  });

  @override
  State<StatefulWidget> createState() => _PasswordInputState(
        controller,
        newPasswordHint,
      );
}

class _PasswordInputState extends State<_PasswordInput> {
  final TextEditingController controller;
  final bool newPasswordHint;

  bool obscure = true;

  void toggle() {
    setState(() {
      obscure = !obscure;
    });
  }

  _PasswordInputState(this.controller, this.newPasswordHint);

  @override
  Widget build(BuildContext context) {
    return StylizedTextField(
      controller: controller,
      autoCorrect: false,
      prefixIcon: FontAwesomeIcons.lock,
      obscureText: obscure,
      autofillHints: [
        newPasswordHint ? AutofillHints.newPassword : AutofillHints.password,
      ],
      textInputAction: TextInputAction.done,
      suffix: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.decelerate,
        switchOutCurve: Curves.decelerate.flipped,
        child: IconButton(
          key: ValueKey(obscure),
          icon: Icon(
            obscure ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
            size: 16,
            color: context.brand.theme.colors.infoText,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }
}

extension on BuildContext {
  ChangePasswordSettingsMainMessages get strings =>
      msg.main.settings.changePassword;
}

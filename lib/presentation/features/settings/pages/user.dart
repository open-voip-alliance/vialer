import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:vialer/presentation/features/settings/widgets/tile/change_password.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/util/context_extensions.dart';

import '../controllers/cubit.dart';
import '../widgets/settings_button.dart';
import '../widgets/tile/mobile_number.dart';
import '../widgets/tile/outgoing_number.dart';
import '../widgets/tile/username.dart';
import 'settings_subpage.dart';

class UserSubPage extends StatelessWidget {
  const UserSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SettingsSubPage(
          cubit: context.watch<SettingsCubit>(),
          title:
              context.msg.main.settings.subPage.user.title(state.user.fullName),
          child: (state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      MobileNumberTile(state.user),
                      OutgoingNumberTile(
                        state.user,
                        enabled: state.shouldAllowRemoteSettings,
                        recentOutgoingNumbers: state.recentOutgoingNumbers,
                      ),
                      UsernameTile(state.user),
                      ChangePasswordTile(state.user),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                KeyboardVisibilityBuilder(
                  builder: (context, isKeyboardVisible) {
                    return Visibility(
                      visible: !isKeyboardVisible,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _LogoutButton(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        );
      },
    );
  }
}

class _LogoutButton extends StatefulWidget {
  const _LogoutButton();

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  final _isLoggingOut = ValueNotifier(false);

  Future<void> _logout() async {
    _isLoggingOut.value = true;
    await context.read<SettingsCubit>().logout();
    _isLoggingOut.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoggingOut,
      builder: (_, isLoggingOut, __) {
        return !isLoggingOut
            ? SettingsButton(
                text: context.msg.main.settings.buttons.logout,
                onPressed: _logout,
                solid: false,
              )
            : CircularProgressIndicator(color: context.colors.primary);
      },
    );
  }
}

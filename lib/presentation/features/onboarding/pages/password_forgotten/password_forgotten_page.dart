import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../resources/localizations.dart';
import '../../../../shared/widgets/stylized_button.dart';
import '../../controllers/password_forgotten/riverpod.dart';
import '../../controllers/password_forgotten/state.dart';
import '../../widgets/background.dart';
import '../../widgets/error.dart';
import '../../widgets/stylized_text_field.dart';

class PasswordForgottenPage extends ConsumerWidget {
  PasswordForgottenPage({
    required this.emailController,
    super.key,
  });

  final TextEditingController emailController;

  void _pop(BuildContext context, [String? message]) {
    // Pop the pages, is not required but maybe pop is in place to make sure if this is called multiple times pop is only called once.
    Navigator.of(context).maybePop(message);
  }

  /// Handles the request for a new password.
  ///
  /// This method is responsible for handling the request for a new password.
  /// It takes the [context], [ref], and [state] as parameters.
  /// If the [state] is not of type [Loading], it closes the keyboard and
  /// calls the `requestNewPassword` method of the [passwordForgottenProvider]
  /// notifier, passing the text from the [emailController].
  void _handleRequestNewPassword(
    BuildContext context,
    WidgetRef ref,
    PasswordForgottenState state,
  ) {
    if (state is! Loading) {
      // Close the keyboard
      FocusScope.of(context).unfocus();
      ref
          .read(passwordForgottenProvider.notifier)
          .requestNewPassword(emailController.text);
    }
  }

  /// Returns the error text based on the given [context] and [state].
  String _errorText(BuildContext context, PasswordForgottenState state) =>
      switch (state) {
        Failure() => context.msg.main.contacts.sharedContacts.form.genericError,
        NotSubmitted state => state.hasValidEmailFormat
            ? ''
            : context.msg.onboarding.login.error.wrongEmailFormat,
        _ => '',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordForgottenState = ref.watch(passwordForgottenProvider);

    /// Listens to changes in the [PasswordForgottenState] and performs an action based on the state.
    /// If the [newState] is of type [Success], it pops a message with the provided success message.
    ref.listen<PasswordForgottenState>(passwordForgottenProvider, (
      PasswordForgottenState? previousState,
      PasswordForgottenState newState,
    ) {
      if (newState is Success)
        _pop(
          context,
          context.msg.onboarding.passwordForgotten.success,
        );
    });

    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Scaffold(
        body: Background(
          style: Style.split,
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 40),
                      onPressed: () => _pop(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Wrap(
                          runSpacing: 40,
                          children: [
                            _Title(),
                            _Description(),
                            _EmailInput(
                              _errorText(context, passwordForgottenState),
                              emailController,
                            ),
                          ],
                        ),
                        Spacer(),
                        StylizedButton.raised(
                          colored: true,
                          onPressed: () => _handleRequestNewPassword(
                            context,
                            ref,
                            passwordForgottenState,
                          ),
                          isLoading: passwordForgottenState is Loading,
                          child: passwordForgottenState is Loading
                              ? PlatformText(
                                  context.msg.onboarding.passwordForgotten
                                      .button.requestingPasswordReset,
                                )
                              : PlatformText(
                                  context.msg.onboarding.passwordForgotten
                                      .button.requestPasswordReset,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  final String errorText;
  final TextEditingController emailController;

  _EmailInput(this.errorText, this.emailController);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StylizedTextField(
          key: Key('emailField'),
          controller: emailController,
          autoCorrect: false,
          prefixIcon: FontAwesomeIcons.envelope,
          labelText: context.msg.onboarding.login.placeholder.email,
          keyboardType: TextInputType.emailAddress,
          hasError: errorText.isNotEmpty,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.done,
        ),
        ErrorAlert(
          key: Key('wrongEmailFormatError'),
          visible: errorText.isNotEmpty,
          inline: true,
          message: errorText,
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.msg.onboarding.passwordForgotten.title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      context.msg.onboarding.passwordForgotten.description,
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
    );
  }
}

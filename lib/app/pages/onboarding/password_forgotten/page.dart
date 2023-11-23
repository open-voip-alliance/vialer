import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../resources/localizations.dart';
import '../widgets/background.dart';
import '../widgets/stylized_text_field.dart';
import '../../../widgets/stylized_button.dart';
import '../widgets/error.dart';
import 'state.dart';

class PasswordForgottenPage extends ConsumerWidget {
  PasswordForgottenPage({
    required this.emailController,
    super.key,
  });

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordForgottenState = ref.watch(passwordForgottenProvider);

    void _pop([String? message]) {
      // Pop the pages, is not required but maybe pop is in place to make sure if this is called multiple times pop is only called once.
      Navigator.of(context).maybePop(message);
    }

    /// Listens to changes in the [PasswordForgottenState] and performs an action based on the state.
    /// If the [newState] is of type [Success], it pops a message with the provided success message.
    ref.listen<PasswordForgottenState>(passwordForgottenProvider,
        (PasswordForgottenState? previousState,
            PasswordForgottenState newState) {
      if (newState is Success)
        _pop(context.msg.onboarding.passwordForgotten.success);
    });

    /// Handles the request for a new password.
    ///
    /// If the [passwordForgottenState] is not [Loading], it closes the keyboard and
    /// calls the `requestNewPassword` method of the [passwordForgottenProvider] with
    /// the text from the [emailController].
    void _handleRequestNewPassword() {
      if (passwordForgottenState is! Loading) {
        // Close the keyboard
        FocusScope.of(context).unfocus();
        ref
            .read(passwordForgottenProvider.notifier)
            .requestNewPassword(emailController.text);
      }
    }

    String _errorText() {
      if (passwordForgottenState is NotSubmitted &&
          !passwordForgottenState.hasValidEmailFormat) {
        return context.msg.onboarding.login.error.wrongEmailFormat;
      }
      if (passwordForgottenState is Failure) {
        return context.msg.main.contacts.sharedContacts.form.genericError;
      }
      return '';
    }

    return Scaffold(
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
                    onPressed: () => _pop(),
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
                          title(context),
                          description(context),
                          emailInput(
                              context, passwordForgottenState, _errorText()),
                        ],
                      ),
                      Spacer(),
                      StylizedButton.raised(
                          colored: true,
                          onPressed: _handleRequestNewPassword,
                          isLoading: passwordForgottenState is Loading,
                          child: passwordForgottenState is Loading
                              ? Text(context.msg.onboarding.passwordForgotten
                                  .button.requestingPasswordReset)
                              : Text(context.msg.onboarding.passwordForgotten
                                  .button.requestPasswordReset)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Center title(BuildContext context) {
    return Center(
      child: Text(context.msg.onboarding.passwordForgotten.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )),
    );
  }

  Text description(BuildContext context) {
    return Text(context.msg.onboarding.passwordForgotten.description,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white60,
        ));
  }

  Column emailInput(BuildContext context,
      PasswordForgottenState passwordForgottenState, String errorText) {
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

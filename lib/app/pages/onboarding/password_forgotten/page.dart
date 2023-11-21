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
    final state = ref.watch(passwordForgottenProvider);

    void _pop([String? message]) {
      Navigator.of(context).pop(message);
    }

    if (state == PasswordForgottenState.success) {
      // Postpone the navigation to the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pop('Your password has been reset. Please check your email.');
      });
    }

    void handleButtonPress() {
      if (state != PasswordForgottenState.loading) {
        ref
            .read(passwordForgottenProvider.notifier)
            .requestNewPassword(emailController.text);
      }
    }

    return Scaffold(
      body: Background(
        style: Style.split,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 40),
                      onPressed: () => _pop()),
                ),
                Wrap(
                  runSpacing: 40,
                  children: [
                    Text('Password forgotten',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                    Text(
                        'Enter your email address below to receive an email with the steps to reset your password.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white60,
                        )),
                    StylizedTextField(
                      key: Key('emailField'),
                      //controller: emailController,
                      autoCorrect: false,
                      prefixIcon: FontAwesomeIcons.envelope,
                      labelText: context.msg.onboarding.login.placeholder.email,
                      keyboardType: TextInputType.emailAddress,
                      hasError: state is Failure,
                      // (loginState is LoginNotSubmitted &&
                      //     !loginState.hasValidEmailFormat),
                      autofillHints: const [AutofillHints.email],
                    ),
                    ErrorAlert(
                      //key: 'test', //LoginPage.keys.wrongEmailFormatError,
                      visible: state == PasswordForgottenState.failure,
                      inline: true,
                      message: 'er gaat wel fout',
                      //context.msg.onboarding.login.error.wrongEmailFormat,
                    ),
                  ],
                ),
                Spacer(),
                StylizedButton.raised(
                    colored: true,
                    onPressed: handleButtonPress,
                    isLoading: state == PasswordForgottenState.loading,
                    child: state == PasswordForgottenState.loading
                        ? Text("Request new password")
                        : Text("Requesting new password"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

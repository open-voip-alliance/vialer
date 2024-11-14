import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../data/models/user/brand.dart';
import '../../../../shared/widgets/error.dart';
import '../../../../shared/widgets/stylized_button.dart';
import '../../../../shared/widgets/stylized_text_field.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../controllers/cubit.dart';
import '../../controllers/mobile_number/cubit.dart';
import '../../widgets/mobile_number/country_field/widget.dart';

class MobileNumberPage extends StatefulWidget {
  const MobileNumberPage({super.key});

  static const keys = _Keys();

  @override
  State<MobileNumberPage> createState() => _MobileNumberPageState();
}

class _MobileNumberPageState extends State<MobileNumberPage> {
  static const _duration = Duration(milliseconds: 200);
  static const _curve = Curves.decelerate;

  final _mobileNumberController = TextEditingController();
  final _mobileNumberFocusNode = FocusNode();

  // Called during build.
  MobileNumberCubit _createCubit() {
    final cubit = MobileNumberCubit();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => mounted
          ? setState(() {
              _mobileNumberController.text = cubit.state.mobileNumber;
            })
          : null,
    );

    _mobileNumberController.addListener(() {
      cubit.validate(_mobileNumberController.text);
    });

    return cubit;
  }

  void _onStateChanged(BuildContext context, MobileNumberState state) {
    if (state is MobileNumberAccepted) {
      context.read<OnboardingCubit>().forward();
    }
  }

  void _onContinueButtonPressed(BuildContext context) {
    unawaited(
      context
          .read<MobileNumberCubit>()
          .changeMobileNumber(_mobileNumberController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _createCubit(),
      child: BlocConsumer<MobileNumberCubit, MobileNumberState>(
        listener: _onStateChanged,
        builder: (context, state) {
          return KeyboardVisibilityBuilder(
            builder: (context, isKeyboardVisible) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                ).copyWith(
                  bottom: 24,
                ),
                child: Center(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        curve: _curve,
                        duration: _duration,
                        height: isKeyboardVisible ? 24 : 64,
                      ),
                      Column(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.mobile,
                            color: context.brand.theme.colors.primary,
                            size: 48,
                          ),
                          SizedBox(height: 24),
                          if (!isKeyboardVisible)
                            Semantics(
                              header: true,
                              child: Text(
                                context.msg.onboarding.mobileNumber.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: context.brand.theme.colors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      AnimatedContainer(
                        curve: _curve,
                        duration: _duration,
                        height: isKeyboardVisible ? 0 : 32,
                      ),
                      Text(
                        context.msg.onboarding.mobileNumber.description(
                          Provider.of<Brand>(context).appName,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ErrorAlert(
                        visible: state is MobileNumberNotAccepted,
                        message: context.msg.main.settings.list.accountInfo
                            .mobileNumber.help,
                        inline: false,
                      ),
                      StylizedTextField(
                        key: MobileNumberPage.keys.field,
                        bordered: true,
                        prefixWidget: CountryFlagField(
                          controller: _mobileNumberController,
                          focusNode: _mobileNumberFocusNode,
                          initialValue: _mobileNumberController.text,
                        ),
                        controller: _mobileNumberController,
                        focusNode: _mobileNumberFocusNode,
                        labelText: context.msg.onboarding.mobileNumber.title,
                        hintText: context.msg.onboarding.mobileNumber.hint,
                        keyboardType: TextInputType.phone,
                        hasError: state is MobileNumberNotAccepted,
                        autoCorrect: false,
                        onSubmitted: (_) => _onContinueButtonPressed(context),
                      ),
                      const SizedBox(height: 16),
                      DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 14,
                          color: context.brand.theme.colors.infoText,
                        ),
                        child: Text(
                          context.msg.onboarding.mobileNumber.info,
                        ),
                      ),
                      if (isKeyboardVisible) SizedBox(height: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: isKeyboardVisible
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: <Widget>[
                            Semantics(
                              button: true,
                              child: StylizedButton.raised(
                                colored: true,
                                key: MobileNumberPage.keys.continueButton,
                                onPressed: state is! MobileNumberNotAccepted
                                    ? () => _onContinueButtonPressed(context)
                                    : null,
                                child: Text(
                                  context.msg.onboarding.mobileNumber.button
                                      .toUpperCaseIfAndroid(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Keys {
  const _Keys();

  Key get field => const Key('mobileNumberField');

  Key get continueButton => const Key('continueButton');
}

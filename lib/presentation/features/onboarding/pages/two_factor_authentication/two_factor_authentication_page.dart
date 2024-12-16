import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../controllers/cubit.dart';
import '../../controllers/two_factor_authentication/cubit.dart';
import '../../widgets/error.dart';
import '../../widgets/stylized_text_field.dart';

class TwoFactorAuthenticationPage extends StatefulWidget {
  const TwoFactorAuthenticationPage({super.key});

  @override
  State<StatefulWidget> createState() => _TwoFactorAuthenticationPageState();
}

class _TwoFactorAuthenticationPageState
    extends State<TwoFactorAuthenticationPage> {
  final _codeFieldKey = GlobalKey<_TwoFactorCodeFieldState>();

  void _onStateChanged(BuildContext context, TwoFactorState state) {
    if (state is PasswordChangeRequired) {
      context.read<OnboardingCubit>().forward();
    }

    if (state is CodeAccepted) {
      // forward after a delay to next page
      Timer(const Duration(seconds: 1), () {
        context.read<OnboardingCubit>().forward();
      });
    }

    if (state is CodeRejected) {
      _codeFieldKey.currentState?.clear();
    }
  }

  /// Attempts to login using the two-factor code, assuming the state is
  /// appropriate.
  Future<void> _loginWithTwoFactorCode({
    required BuildContext context,
    required TwoFactorState state,
    required String code,
  }) async {
    if (state is AwaitingServerResponse || state is CodeAccepted) return;

    await context
        .read<TwoFactorAuthenticationCubit>()
        .attemptLoginWithTwoFactorCode(code);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Provider.of<EdgeInsets>(context).copyWith(top: 32),
      child: BlocProvider<TwoFactorAuthenticationCubit>(
        create: (context) => TwoFactorAuthenticationCubit(
          context.read<OnboardingCubit>(),
        ),
        child: BlocConsumer<TwoFactorAuthenticationCubit, TwoFactorState>(
          listener: _onStateChanged,
          builder: (context, state) {
            return Column(
              children: <Widget>[
                FaIcon(
                  FontAwesomeIcons.shieldKeyhole,
                  color: context.brand.theme.colors.primary,
                  size: 48,
                ),
                SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(
                    context.msg.onboarding.twoFactor.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: context.brand.theme.colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  context.msg.onboarding.twoFactor.message,
                ),
                const SizedBox(height: 16),
                ErrorAlert(
                  visible: state is CodeRejected,
                  inline: false,
                  message: context.msg.onboarding.twoFactor.wrongCode,
                ),
                _TwoFactorCodeField(
                  key: _codeFieldKey,
                  onCodeSubmitted: (code) => unawaited(
                    _loginWithTwoFactorCode(
                      context: context,
                      code: code,
                      state: state,
                    ),
                  ),
                ),
                if (state is CodeAccepted)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.check,
                          size: 60,
                          color: context.brand.theme.colors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(context.msg.onboarding.twoFactor.success),
                      ],
                    ),
                  ),
                if (state is AwaitingServerResponse)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              context.brand.theme.colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TwoFactorCodeField extends StatefulWidget {
  const _TwoFactorCodeField({
    required GlobalKey key,
    required this.onCodeSubmitted,
  }) : super(key: key);
  final void Function(String code) onCodeSubmitted;

  @override
  _TwoFactorCodeFieldState createState() => _TwoFactorCodeFieldState();
}

class _TwoFactorCodeFieldState extends State<_TwoFactorCodeField>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  late FocusScopeNode _focusScope;

  /// The amount of inputs generated is based on how many controllers we create
  /// in this list.
  final _textEditingControllers =
      List.generate(6, (_) => TextEditingController());

  /// The current code that the user has entered.
  String get _currentCode =>
      _textEditingControllers.map((e) => e.value.text).join();

  /// The last code that we reported, used to avoid reporting the same code
  /// multiple times.
  var _lastCodeSubmitted = '';

  @override
  void initState() {
    _focusScope = FocusScopeNode();

    for (final controller in _textEditingControllers) {
      controller.addListener(_handleTextInputChanged);
    }

    super.initState();
  }

  /// Clears the user input from the input field.
  void clear() {
    _lastCodeSubmitted = '';

    for (final controller in _textEditingControllers) {
      controller.text = '';
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      FocusScope.of(context).unfocus();

      /// Clipboard data is only available to the app that is currently in focus
      /// we will try to access it after a short delay to make sure that we are
      /// properly in focus first.
      Timer(const Duration(milliseconds: 100), () async {
        final data = await Clipboard.getData('text/plain');

        if (data?.text != null) {
          _populateCodeField(data!.text!);
        }
      });
    }
  }

  bool _looksLikeTwoFactorCode(String code) {
    if (code.length != 6) return false;

    return RegExp(r'^[0-9]+$').hasMatch(code);
  }

  void _populateCodeField(String code) {
    if (!_looksLikeTwoFactorCode(code)) return;

    for (var i = 0; i < _textEditingControllers.length; i++) {
      _textEditingControllers[i].text = code.length > i ? code[i] : '';
    }
  }

  void _handleTextInputChanged() {
    if (_currentCode.length == _textEditingControllers.length) {
      _focusScope.unfocus();

      if (_lastCodeSubmitted != _currentCode) {
        _lastCodeSubmitted = _currentCode;
        widget.onCodeSubmitted(_currentCode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _focusScope,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ..._buildFields(),
        ],
      ),
    );
  }

  List<_TwoFactorDigitField> _buildFields() => _textEditingControllers
      .map((e) => _TwoFactorDigitField(controller: e, focusScope: _focusScope))
      .toList();

  @override
  void dispose() {
    for (final controller in _textEditingControllers) {
      controller.dispose();
    }

    super.dispose();
  }
}

class _TwoFactorDigitField extends StatelessWidget {
  const _TwoFactorDigitField({
    required this.controller,
    required this.focusScope,
  });

  final TextEditingController controller;
  final FocusScopeNode focusScope;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: StylizedTextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
          ],
          autoCorrect: false,
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
          onEditingComplete: focusScope.nextFocus,
          onChanged: (text) => {
            if (text.isNotEmpty) {focusScope.nextFocus()},
          },
          onTap: () => controller.text = '',
        ),
      ),
    );
  }
}

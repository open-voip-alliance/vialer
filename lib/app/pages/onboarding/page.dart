import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:vialer/app/pages/onboarding/permission/ignore_battery_optimization/page.dart';

import '../../../domain/entities/onboarding/step.dart';
import '../../routes.dart';
import '../main/widgets/caller.dart';
import 'cubit.dart';
import 'login/page.dart';
import 'mobile_number/page.dart';
import 'password/page.dart';
import 'permission/bluetooth/page.dart';
import 'permission/call/page.dart';
import 'permission/contacts/page.dart';
import 'permission/microphone/page.dart';
import 'two_factor_authentication/page.dart';
import 'voicemail/page.dart';
import 'welcome/page.dart';
import 'widgets/background.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _duration = Duration(milliseconds: 400);
  static const _curve = Curves.decelerate;

  final _pageController = PageController();

  late Map<OnboardingStep, WidgetBuilder> _allPages;
  late Map<OnboardingStep, WidgetBuilder> _currentPages;

  @override
  void initState() {
    super.initState();

    _allPages = {
      OnboardingStep.login: (_) => LoginPage(),
      OnboardingStep.password: (_) => PasswordPage(),
      OnboardingStep.twoFactorAuthentication: (_) =>
          const TwoFactorAuthenticationPage(),
      OnboardingStep.mobileNumber: (_) => MobileNumberPage(),
      OnboardingStep.callPermission: (_) => const CallPermissionPage(),
      OnboardingStep.microphonePermission: (_) =>
          const MicrophonePermissionPage(),
      OnboardingStep.contactsPermission: (_) => const ContactsPermissionPage(),
      OnboardingStep.bluetoothPermission: (_) =>
          const BluetoothPermissionPage(),
      OnboardingStep.ignoreBatteryOptimizationsPermission: (_) =>
      const IgnoreBatteryOptimizationsPermissionPage(),
      OnboardingStep.voicemail: (_) => const VoicemailPage(),
      OnboardingStep.welcome: (_) => WelcomePage(),
    };

    _currentPages = Map.fromEntries([_allPages.entries.first]);
  }

  void _onStateChange(BuildContext context, OnboardingState state) {
    // Update current pages only if there's a size change.
    if (_currentPages.length != state.allSteps.length) {
      _currentPages = Map.fromEntries(
        state.allSteps.map((s) => MapEntry(s, _allPages[s]!)),
      );
    }

    if (state.completed) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.main, (_) => false);
      return;
    }

    final newIndex = _currentPages.keys.toList().indexOf(state.currentStep);

    _pageController.animateToPage(
      newIndex,
      duration: _duration,
      curve: _curve,
    );
  }

  Future<bool> _backward(BuildContext context) async {
    final cubit = context.read<OnboardingCubit>();

    if (cubit.state.currentStep == cubit.state.allSteps.first) {
      return true;
    } else {
      cubit.backward();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: BlocProvider<OnboardingCubit>(
          create: (_) => OnboardingCubit(
            context.watch<CallerCubit>(),
          ),
          child: BlocConsumer<OnboardingCubit, OnboardingState>(
            listener: _onStateChange,
            builder: (context, state) {
              return WillPopScope(
                onWillPop: () => _backward(context),
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white),
                  child: IconTheme(
                    data: const IconThemeData(color: Colors.white),
                    child: PageView(
                      controller: _pageController,
                      children: _currentPages.entries.map((entry) {
                        final page = entry.value;
                        return SafeArea(
                          child: Provider<EdgeInsets>(
                            create: (_) => const EdgeInsets.all(48).copyWith(
                              top: 128,
                              bottom: 32,
                            ),
                            child: page(context),
                          ),
                        );
                      }).toList(),
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

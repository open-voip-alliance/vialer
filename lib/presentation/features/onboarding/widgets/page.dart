import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';

import '../../../../../data/models/onboarding/step.dart';
import '../../../routes.dart';
import '../../../shared/widgets/caller.dart';
import '../controllers/cubit.dart';
import '../pages/login/login_page.dart';
import '../pages/mobile_number/mobile_number_page.dart';
import '../pages/password/password_page.dart';
import '../pages/permission/bluetooth/bluetooth_permission_page.dart';
import '../pages/permission/contacts/contacts_permission_page.dart';
import '../pages/permission/ignore_battery_optimizations/ignore_battery_opts_page.dart';
import '../pages/permission/microphone/mic_permission_page.dart';
import '../pages/permission/notifications/notifications_permission_page.dart';
import '../pages/permission/phone/phone_perimission_page.dart';
import '../pages/two_factor_authentication/two_factor_authentication_page.dart';
import '../pages/welcome/welocome_page.dart';
import 'background.dart';

class OnboardingPage extends StatefulWidget {
  /// Only one can exist in the widget tree.
  OnboardingPage() : super(key: keys.page);

  @override
  State<StatefulWidget> createState() => OnboardingPageState();

  static final keys = _Keys();
}

@visibleForTesting
class OnboardingPageState extends State<OnboardingPage> {
  static const _duration = Duration(milliseconds: 400);
  static const _curve = Curves.decelerate;

  @visibleForTesting
  final pageController = PageController();

  late Map<OnboardingStep, WidgetBuilder> _allPages;
  @visibleForTesting
  late Map<OnboardingStep, WidgetBuilder> currentPages;

  @override
  void initState() {
    super.initState();

    _allPages = {
      OnboardingStep.login: (_) => const LoginPage(),
      OnboardingStep.password: (_) => const PasswordPage(),
      OnboardingStep.twoFactorAuthentication: (_) =>
          const TwoFactorAuthenticationPage(),
      OnboardingStep.mobileNumber: (_) => const MobileNumberPage(),
      OnboardingStep.phonePermission: (_) => const PhonePermissionPage(),
      OnboardingStep.microphonePermission: (_) =>
          const MicrophonePermissionPage(),
      OnboardingStep.contactsPermission: (_) => const ContactsPermissionPage(),
      OnboardingStep.bluetoothPermission: (_) =>
          const BluetoothPermissionPage(),
      OnboardingStep.ignoreBatteryOptimizationsPermission: (_) =>
          const IgnoreBatteryOptimizationsPermissionPage(),
      OnboardingStep.notificationPermission: (_) =>
          const NotificationsPermissionPage(),
      OnboardingStep.welcome: (_) => const WelcomePage(),
    };

    currentPages = Map.fromEntries([_allPages.entries.first]);
  }

  void _onStateChange(BuildContext context, OnboardingState state) {
    // Update current pages only if there's a size change.
    if (currentPages.length != state.allSteps.length) {
      currentPages = Map.fromEntries(
        state.allSteps.map((s) => MapEntry(s, _allPages[s]!)),
      );
    }

    if (state.completed) {
      unawaited(
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.main, (_) => false),
      );
      return;
    }

    final newIndex = currentPages.keys.toList().indexOf(state.currentStep);

    unawaited(
      pageController.animateToPage(
        newIndex,
        duration: _duration,
        curve: _curve,
      ),
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
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Provider<EdgeInsets>(
        create: (_) => const EdgeInsets.all(48).copyWith(top: 128, bottom: 32),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: BlocProvider<OnboardingCubit>(
            create: (_) => OnboardingCubit(context.watch<CallerCubit>()),
            child: BlocConsumer<OnboardingCubit, OnboardingState>(
              listener: _onStateChange,
              buildWhen: (prev, current) =>
                  prev.currentStep.asBackgroundStyle() !=
                  current.currentStep.asBackgroundStyle(),
              builder: (context, state) {
                return Background(
                  style: state.currentStep.asBackgroundStyle(),
                  child: PopScope(
                    onPopInvokedWithResult: (_, __) async => _backward(context),
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Colors.black),
                      child: IconTheme(
                        data: const IconThemeData(color: Colors.white),
                        child: PageView(
                          controller: pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: currentPages.entries.map((entry) {
                            final page = entry.value;
                            return Semantics(
                              explicitChildNodes: true,
                              child: SafeArea(child: page(context)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Keys {
  final page = GlobalKey<OnboardingPageState>();
}

extension on OnboardingStep {
  /// Defines the type of background we should be using based on what onboarding
  /// step we are on.
  Style asBackgroundStyle() => switch (this) {
        OnboardingStep.login => Style.triangle,
        OnboardingStep.password => Style.split,
        _ => Style.cascading,
      };
}

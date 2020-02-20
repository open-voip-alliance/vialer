import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../mappers/step.dart';
import '../../../domain/repositories/call_permission.dart';
import '../../../domain/entities/onboarding/step.dart';

import '../../routes.dart';
import 'presenter.dart';

import 'initial/page.dart';
import 'login/page.dart';
import 'permission/call/page.dart';

class OnboardingController extends Controller {
  static const _duration = Duration(milliseconds: 400);
  static const _curve = Curves.decelerate;

  final OnboardingPresenter _presenter;

  final pageController = PageController();

  Map<Type, WidgetBuilder> _pageBuilders;
  List<WidgetBuilder> pages;

  OnboardingController(CallPermissionRepository callPermissionRepository)
      : _presenter = OnboardingPresenter(callPermissionRepository);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    _pageBuilders = {
      InitialPage: (_) => InitialPage(forward),
      LoginPage: (_) => LoginPage(forward),
      CallPermissionPage: (_) => CallPermissionPage(forward),
    };

    pages = [_pageBuilders[InitialPage]];

    _presenter.getSteps();
  }

  void forward() {
    final index = pageController.page.round() + 1;

    if (index >= pages.length) {
      Navigator.pushNamedAndRemoveUntil(
        getContext(),
        Routes.main,
        (_) => false,
      );
    } else {
      _goTo(index);
    }
  }

  Future<bool> backward() async {
    final index = pageController.page.round() - 1;

    if (index < 0) {
      return true;
    } else {
      await _goTo(index);
      return false;
    }
  }

  Future<void> _goTo(int index) async {
    await pageController.animateToPage(
      index,
      duration: _duration,
      curve: _curve,
    );
  }

  void _setRequiredSteps(List<Step> steps) {
    pages = mapStepsToWidgetTypes(steps)
        .map((type) => _pageBuilders[type])
        .toList();

    refreshUI();
  }

  @override
  void initListeners() {
    _presenter.getStepsOnNext = _setRequiredSteps;
  }
}

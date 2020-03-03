import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:provider/provider.dart';

import '../../mappers/step.dart';

import '../../../domain/repositories/auth.dart';
import '../../../domain/repositories/permission.dart';
import '../../../domain/entities/onboarding/step.dart';

import '../../routes.dart';
import 'presenter.dart';

import 'initial/page.dart';
import 'login/page.dart';
import 'permission/call/page.dart';
import 'permission/contacts/page.dart';

class OnboardingController extends Controller {
  static const _duration = Duration(milliseconds: 400);
  static const _curve = Curves.decelerate;

  final OnboardingPresenter _presenter;

  final pageController = PageController();

  Map<Type, WidgetBuilder> _pageBuilders;
  List<WidgetBuilder> pages;

  OnboardingController(PermissionRepository permissionRepository)
      : _presenter = OnboardingPresenter(permissionRepository);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    _pageBuilders = {
      InitialPage: (_) => InitialPage(forward),
      LoginPage: (c) => LoginPage(Provider.of<AuthRepository>(c), forward),
      CallPermissionPage: (c) => CallPermissionPage(
            Provider.of<PermissionRepository>(c),
            forward,
          ),
      ContactsPermissionPage: (c) => ContactsPermissionPage(
            Provider.of<PermissionRepository>(c),
            forward,
          ),
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

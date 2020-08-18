import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../mappers/step.dart';

import '../../../domain/entities/onboarding/step.dart';

import '../../routes.dart';
import 'presenter.dart';

import 'login/page.dart';
import 'password/page.dart';
import 'permission/call/page.dart';
import 'permission/contacts/page.dart';
import 'voicemail/page.dart';
import 'welcome/page.dart';

class OnboardingController extends Controller {
  static const _duration = Duration(milliseconds: 400);
  static const _curve = Curves.decelerate;

  final _presenter = OnboardingPresenter();

  final pageController = PageController();

  Map<Type, WidgetBuilder> _pageBuilders;
  List<WidgetBuilder> pages;

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    _pageBuilders = {
      LoginPage: (c) => LoginPage(forward, addStep),
      PasswordPage: (c) => PasswordPage(forward, addStep),
      CallPermissionPage: (c) => CallPermissionPage(forward),
      ContactsPermissionPage: (c) => ContactsPermissionPage(forward),
      VoicemailPage: (_) => VoicemailPage(forward),
      WelcomePage: (c) => WelcomePage(forward),
    };

    pages = [_pageBuilders[LoginPage]];

    _presenter.getSteps();
  }

  /// Add a new next step.
  void addStep(Step step) {
    final currentPage = pageController.page.round();

    pages.insert(currentPage + 1, _pageBuilders[step.widgetType]);

    refreshUI();
  }

  void forward() {
    final index = pageController.page.round() + 1;

    if (index >= pages.length) {
      logger.info('Onboarding complete');
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
    String displayReturnType(Type type) => type.toString().split(' => ')[1];

    logger.info(
      'Progress step: '
      '${displayReturnType(pages[index - 1].runtimeType)}'
      ' -> ${displayReturnType(pages[index].runtimeType)}',
    );

    await pageController.animateToPage(
      index,
      duration: _duration,
      curve: _curve,
    );
  }

  void _setRequiredSteps(List<Step> steps) {
    pages = steps.widgetTypes.map((type) => _pageBuilders[type]).toList();

    refreshUI();
  }

  @override
  void initListeners() {
    _presenter.getStepsOnNext = _setRequiredSteps;
  }
}

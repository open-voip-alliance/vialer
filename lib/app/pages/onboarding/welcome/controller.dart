import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/system_user.dart';
import '../../../../domain/repositories/auth.dart';

import 'presenter.dart';

class WelcomeController extends Controller {
  final WelcomePresenter _presenter;

  final VoidCallback _forward;

  SystemUser _systemUser;

  SystemUser get systemUser => _systemUser;

  WelcomeController(
    AuthRepository authRepository,
    this._forward,
  ) : _presenter = WelcomePresenter(authRepository);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    getCurrentUser();
  }

  void getCurrentUser() => _presenter.getCurrentUser();

  void _onRetrievedUser(SystemUser user) {
    _systemUser = user;
    refreshUI();
    Timer(Duration(milliseconds: 1500), _forward);
  }

  @override
  void initListeners() {
    _presenter.currentUserOnNext = _onRetrievedUser;
  }
}

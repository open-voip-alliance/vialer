import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/repositories/call_permission.dart';

import 'presenter.dart';

class CallPermissionController extends Controller {
  final CallPermissionPresenter _presenter;

  final VoidCallback _forward;

  CallPermissionController(
    CallPermissionRepository callPermissionRepository,
    this._forward,
  ) : _presenter = CallPermissionPresenter(callPermissionRepository);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);
  }

  void ask() => _presenter.ask();

  void _onAsked(bool granted) {
    if (granted) {
      _forward();
    }

    // TODO: Show error on fail
  }

  @override
  void initListeners() {
    _presenter.requestCallPermissionOnNext = _onAsked;
  }
}

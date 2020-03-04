import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_segment/flutter_segment.dart';

import '../../../../../domain/entities/onboarding/permission.dart';
import '../../../../../domain/repositories/permission.dart';

import '../../../../util/debug.dart';

import 'presenter.dart';

class PermissionController extends Controller {
  final Permission permission;

  final PermissionPresenter _presenter;

  final VoidCallback _forward;

  PermissionController(
    this.permission,
    PermissionRepository permissionRepository,
    this._forward,
  ) : _presenter = PermissionPresenter(permissionRepository);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);
  }

  void ask() => _presenter.ask(permission);

  void _onAsked(bool granted) {
    if (granted) {
      _forward();
    }

    //doIfNotDebug(() {
      Segment.track(
        eventName: 'permission',
        properties: {
          'type': permission.toShortString(),
          'granted': granted,
        },
      );
    //});

    // TODO: Show error on fail
  }

  @override
  void initListeners() {
    _presenter.requestPermissionOnNext = _onAsked;
  }
}

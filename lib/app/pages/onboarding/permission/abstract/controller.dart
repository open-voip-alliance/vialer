import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_segment/flutter_segment.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/entities/permission_status.dart';

import '../../../../util/debug.dart';

import 'presenter.dart';

class PermissionController extends Controller {
  final Permission permission;

  final _presenter = PermissionPresenter();

  final VoidCallback _forward;

  PermissionController(
    this.permission,
    this._forward,
  );

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);
  }

  void ask() {
    logger.info('Asking permission for "${permission.toShortString()}"');
    _presenter.ask(permission);
  }

  void _onAsked(PermissionStatus status) {
    if (status == PermissionStatus.granted) {
      logger.info('Permission granted for: "${permission.toShortString()}"');
      _forward();
    } else {
      logger.info('Permission denied for: "${permission.toShortString()}"');
      _forward();
    }

    doIfNotDebug(() {
      Segment.track(
        eventName: 'permission',
        properties: {
          'type': permission.toShortString(),
          'granted': status == PermissionStatus.granted,
        },
      );
    });

    // TODO: Show error on fail
  }

  @override
  void initListeners() {
    _presenter.requestPermissionOnNext = _onAsked;
  }
}

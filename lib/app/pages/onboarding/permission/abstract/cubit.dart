import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_segment/flutter_segment.dart';

import '../../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/entities/permission_status.dart';

import '../../../../util/debug.dart';
import '../../../../util/loggable.dart';

import 'state.dart';
export 'state.dart';

class PermissionCubit extends Cubit<PermissionState> with Loggable {
  final _requestPermission = RequestPermissionUseCase();

  final Permission permission;

  PermissionCubit(this.permission) : super(PermissionNotRequested());

  Future<void> request() async {
    logger.info('Asking permission for "${permission.toShortString()}"');

    final status = await _requestPermission(permission: permission);

    if (status == PermissionStatus.granted) {
      logger.info('Permission granted for: "${permission.toShortString()}"');
      emit(PermissionGranted());
    } else {
      logger.info('Permission denied for: "${permission.toShortString()}"');
      emit(PermissionDenied());
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
}

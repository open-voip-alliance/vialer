import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/entities/permission_status.dart';
import '../../../../../domain/usecases/metrics/track_permission.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../../util/loggable.dart';
import 'state.dart';

export 'state.dart';

class PermissionCubit extends Cubit<PermissionState> with Loggable {
  final _requestPermission = RequestPermissionUseCase();
  final _trackPermission = TrackPermissionUseCase();

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

    _trackPermission(
      type: permission.toShortString(),
      granted: status == PermissionStatus.granted,
    );
  }
}

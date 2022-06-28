import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/check_app_updates.dart';
import '../../../domain/usecases/complete_flexible_update.dart';
import '../../../domain/usecases/get_build_info.dart';
import '../../../domain/usecases/get_did_app_update_to_new_version.dart';
import '../../pages/main/widgets/caller.dart';
import 'state.dart';

export 'state.dart';

class AppUpdateCheckerCubit extends Cubit<AppUpdateState> {
  final CallerCubit caller;

  final _getDidAppUpdateToNewVersion = GetDidAppUpdateToNewVersionUseCase();
  final _getBuildInfo = GetBuildInfoUseCase();
  final _checkAppUpdates = CheckAppUpdatesUseCase();
  final _completeFlexibleUpdate = CompleteFlexibleUpdateUseCase();

  bool _checking = false;

  AppUpdateCheckerCubit(this.caller) : super(const AppWasNotUpdated()) {
    check();
  }

  Future<void> check() async {
    // We won't check if we're already checking, if an update is ready to
    // install or we're in a call.
    if (_checking ||
        state is UpdateReadyToInstall ||
        caller.state.isInCall ||
        caller.processState.voipCall != null) {
      return;
    }

    _checking = true;

    final isFlexibleUpdateAndHasDownloaded = await _checkAppUpdates();

    if (isFlexibleUpdateAndHasDownloaded && !caller.state.isInCall) {
      emit(const UpdateReadyToInstall());
      _checking = false;
      return;
    }

    await _emitBasedOnRelease(await _getDidAppUpdateToNewVersion());
    _checking = false;
  }

  void completeFlexibleUpdate() => _completeFlexibleUpdate();

  Future<void> _emitBasedOnRelease(bool hasNewRelease) async => emit(
        hasNewRelease
            ? NewUpdateWasInstalled(
                await _getBuildInfo().then((buildInfo) => buildInfo.version),
              )
            : const AppWasNotUpdated(),
      );
}

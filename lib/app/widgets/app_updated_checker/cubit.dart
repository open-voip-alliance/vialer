import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_build_info.dart';
import '../../../domain/usecases/get_did_app_update_to_new_version.dart';

import 'state.dart';

export 'state.dart';

class AppUpdatedCheckerCubit extends Cubit<AppUpdatedState> {
  final _getDidAppUpdateToNewVersion = GetDidAppUpdateToNewVersionUseCase();
  final _getBuildInfo = GetBuildInfoUseCase();

  AppUpdatedCheckerCubit() : super(AppWasNotUpdated()) {
    check();
  }

  Future<void> check() async =>
      _emitBasedOnRelease(await _getDidAppUpdateToNewVersion());

  void _emitBasedOnRelease(bool hasNewRelease) async => emit(
        hasNewRelease
            ? NewUpdateWasInstalled(
                await _getBuildInfo().then((buildInfo) => buildInfo.version),
              )
            : AppWasNotUpdated(),
      );
}

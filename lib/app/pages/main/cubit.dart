import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dependency_locator.dart';
import '../../../domain/entities/setting.dart';
import '../../../domain/repositories/storage.dart';
import '../../../domain/usecases/get_latest_voipgrid_permissions.dart';
import '../../../domain/usecases/get_setting.dart';

class MainState {
  const MainState();
}

class MainCubit extends Cubit<MainState> {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _getLatestVoipgridPermissions = GetLatestVoipgridPermissions();
  final _getShowClientCallsSetting =
      GetSettingUseCase<ShowClientCallsSetting>();

  MainCubit() : super(const MainState());

  void markRecentCallsShown() {
    _storageRepository.shownRecentCalls = true;
  }

  Future<bool> shouldShowClientWideCallsDialog() async =>
      (await _getLatestVoipgridPermissions()).hasClientCallsPermission &&
      !(_storageRepository.shownRecentCalls ?? false) &&
      (await _getShowClientCallsSetting()).value == false;
}

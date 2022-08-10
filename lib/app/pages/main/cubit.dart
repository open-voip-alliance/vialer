import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dependency_locator.dart';
import '../../../domain/repositories/storage.dart';
import '../../../domain/usecases/get_latest_voipgrid_permissions.dart';

class MainState {
  const MainState();
}

class MainCubit extends Cubit<MainState> {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _getLatestVoipgridPermissions = GetLatestVoipgridPermissions();

  MainCubit() : super(const MainState());

  void markRecentCallsShown() {
    _storageRepository.shownRecentCalls = true;
  }

  Future<bool> shouldShowClientWideCallsDialog() async =>
      (await _getLatestVoipgridPermissions()).hasClientCallsPermission &&
      !(_storageRepository.shownRecentCalls ?? false);
}

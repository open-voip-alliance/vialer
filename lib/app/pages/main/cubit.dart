import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dependency_locator.dart';
import '../../../domain/legacy/storage.dart';
import '../../../domain/user/get_logged_in_user.dart';

class MainState {
  const MainState();
}

class MainCubit extends Cubit<MainState> {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _getLatestUser = GetLoggedInUserUseCase();

  MainCubit() : super(const MainState());

  void markRecentCallsShown() {
    _storageRepository.shownRecentCalls = true;
  }

  Future<bool> shouldShowClientWideCallsDialog() async =>
      (await _getLatestUser().permissions).canSeeClientCalls &&
      !(_storageRepository.shownRecentCalls ?? false);
}

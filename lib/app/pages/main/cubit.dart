import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dependency_locator.dart';
import '../../../domain/repositories/storage.dart';

class MainState {
  const MainState();
}

class MainCubit extends Cubit<MainState> {
  final _storageRepository = dependencyLocator<StorageRepository>();

  MainCubit() : super(const MainState());

  void markRecentCallsShown() {
    _storageRepository.shownRecents = true;
  }

  bool shouldShowClientWideCallsDialog() {
    final shownRecents = _storageRepository.shownRecents ?? false;
    return !shownRecents;
  }
}

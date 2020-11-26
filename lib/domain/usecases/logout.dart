import '../../dependency_locator.dart';
import '../entities/setting.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class LogoutUseCase extends UseCase<void> {
  final _storageRepository = dependencyLocator<StorageRepository>();

  @override
  void call() {
    final remoteLoggingSetting =
        _storageRepository.settings.get<RemoteLoggingSetting>();

    _storageRepository
      ..clear()
      ..settings = [
        remoteLoggingSetting,
      ];
  }
}

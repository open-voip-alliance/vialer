import '../../dependency_locator.dart';
import '../entities/server_config.dart';
import '../repositories/server_config.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class GetServerConfigUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _serverConfigRepository = dependencyLocator<ServerConfigRepository>();

  /// Gets the currently saved server config. If it's null or [latest]
  /// is true, it's fetched from the API.
  Future<ServerConfig> call({bool latest = false}) async {
    var serverConfig = _storageRepository.serverConfig;

    if (latest || serverConfig == null) {
      serverConfig = await _serverConfigRepository.get();
      _storageRepository.serverConfig = serverConfig;
    }

    return serverConfig;
  }
}

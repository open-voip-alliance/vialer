import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../entities/server_config.dart';
import '../repositories/metrics.dart';
import '../repositories/server_config.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class GetServerConfigUseCase extends UseCase with Loggable {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _serverConfigRepository = dependencyLocator<ServerConfigRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  /// Gets the currently saved server config. If it's null or [latest]
  /// is true, it's fetched from the API.
  Future<ServerConfig> call({bool latest = false}) async {
    var currentServerConfig = _storageRepository.serverConfig;

    if (!latest && currentServerConfig != null) {
      return currentServerConfig;
    }

    final latestServerConfig = await _serverConfigRepository.get();
    _storageRepository.serverConfig = latestServerConfig;

    _track(
      current: currentServerConfig,
      latest: latestServerConfig,
    );

    return latestServerConfig;
  }

  void _track({
    required ServerConfig? current,
    required ServerConfig latest,
  }) {
    if (current == null) {
      logger.info('Loaded SERVER CONFIG: $latest');
      return;
    }

    if (current != latest) {
      _metricsRepository.track('server-config-changed', {
        'from': current,
        'to': latest,
      });

      logger.info(
        'Switching SERVER CONFIG from '
        '[$current] to [$latest]',
      );
    }
  }
}

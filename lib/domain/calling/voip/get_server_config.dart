import '../../../app/util/loggable.dart';
import '../../../dependency_locator.dart';
import '../../legacy/storage.dart';
import '../../metrics/metrics.dart';
import '../../use_case.dart';
import '../../voipgrid/server_config.dart';
import 'server_config.dart';

class GetServerConfigUseCase extends UseCase with Loggable {
  late final _storageRepository = dependencyLocator<StorageRepository>();
  late final _serverConfigRepository =
      dependencyLocator<ServerConfigRepository>();
  late final _metricsRepository = dependencyLocator<MetricsRepository>();

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
        'Switching SERVER CONFIG from [$current] to [$latest]',
      );
    }
  }
}

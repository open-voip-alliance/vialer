// ignore_for_file: avoid_types_on_closure_parameters

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../calling/voip/client_voip_config_repository.dart';
import '../../../metrics/metrics.dart';
import '../../../voipgrid/client_voip_config.dart';
import '../../client.dart';
import '../user_refresh_task_performer.dart';

class RefreshClientVoipConfig extends ClientRefreshTaskPerformer with Loggable {
  late final _clientVoipConfigRepository =
      dependencyLocator<ClientVoipConfigRepository>();
  late final _metricsRepository = dependencyLocator<MetricsRepository>();

  @override
  Future<ClientMutator> performClientRefreshTask(Client client) async {
    final current = client.voip;
    final latest = await _clientVoipConfigRepository.get();

    if (current != latest) {
      _trackAndLogNewClientVoipConfig(current, latest);
    }

    return (Client client) => client.copyWith(voip: latest);
  }

  void _trackAndLogNewClientVoipConfig(
    ClientVoipConfig current,
    ClientVoipConfig latest,
  ) {
    if (current.isFallback) {
      logger.info('Loaded CLIENT VOIP CONFIG: $latest');
      return;
    }

    _metricsRepository.track('server-config-changed', {
      'from': current,
      'to': latest,
    });

    logger.info(
      'Switching CLIENT VOIP CONFIG from [$current] to [$latest]',
    );
  }
}

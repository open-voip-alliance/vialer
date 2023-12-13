import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../calling/voip/client_voip_config_repository.dart';
import '../../../metrics/metrics.dart';
import '../../../voipgrid/client_voip_config.dart';
import '../../client.dart';
import '../user_refresh_task_performer.dart';

class RefreshClientVoipConfig extends ClientRefreshTaskPerformer {
  const RefreshClientVoipConfig();

  @override
  Future<ClientMutator> performClientRefreshTask(Client client) async {
    final current = client.voip;
    final latest = await dependencyLocator<ClientVoipConfigRepository>().get();

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

    dependencyLocator<MetricsRepository>().track('server-config-changed', {
      'from': current.toString(),
      'to': latest.toString(),
    });

    logger.info(
      'Switching CLIENT VOIP CONFIG from [$current] to [$latest]',
    );
  }
}

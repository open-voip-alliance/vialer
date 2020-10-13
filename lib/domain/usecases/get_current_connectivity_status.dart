import '../../dependency_locator.dart';
import '../use_case.dart';

import '../repositories/connectivity_repository.dart';
import '../connectivity_status.dart';

class GetCurrentConnectivityStatusUseCase
    extends FutureUseCase<ConnectivityStatus> {
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  @override
  Future<ConnectivityStatus> call() => _connectivityRepository.currentStatus;
}

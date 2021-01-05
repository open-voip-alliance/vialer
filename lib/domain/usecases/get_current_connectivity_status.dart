import '../../dependency_locator.dart';
import '../connectivity_status.dart';
import '../repositories/connectivity.dart';
import '../use_case.dart';

class GetCurrentConnectivityStatusUseCase
    extends FutureUseCase<ConnectivityStatus> {
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  @override
  Future<ConnectivityStatus> call() => _connectivityRepository.currentStatus;
}

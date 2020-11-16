import '../../dependency_locator.dart';
import '../connectivity_status.dart';
import '../repositories/connectivity_repository.dart';
import '../use_case.dart';

class GetConnectivityStatusStreamUseCase
    extends StreamUseCase<ConnectivityStatus> {
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  @override
  Stream<ConnectivityStatus> call() => _connectivityRepository.statusStream;
}

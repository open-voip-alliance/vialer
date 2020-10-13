import '../../dependency_locator.dart';
import '../use_case.dart';

import '../repositories/connectivity_repository.dart';
import '../connectivity_status.dart';

class GetConnectivityStatusStreamUseCase
    extends StreamUseCase<ConnectivityStatus> {
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  @override
  Stream<ConnectivityStatus> call() => _connectivityRepository.statusStream;
}

import '../../../../data/models/user/connectivity/connectivity_type.dart';
import '../../../../data/repositories/user/connectivity/connectivity.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

class GetConnectivityTypeStreamUseCase extends UseCase {
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Stream<ConnectivityType> call() => _connectivityRepository.statusStream;
}

import '../../../../data/models/user/connectivity/connectivity_type.dart';
import '../../../../data/repositories/user/connectivity/connectivity.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

class GetCurrentConnectivityTypeUseCase extends UseCase {
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Future<ConnectivityType> call() => _connectivityRepository.currentType;
}

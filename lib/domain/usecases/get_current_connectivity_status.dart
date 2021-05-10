import '../../dependency_locator.dart';
import '../connectivity_type.dart';
import '../repositories/connectivity.dart';
import '../use_case.dart';

class GetCurrentConnectivityTypeUseCase extends UseCase {
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Future<ConnectivityType> call() => _connectivityRepository.currentType;
}

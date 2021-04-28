import '../../dependency_locator.dart';
import '../connectivity_type.dart';
import '../repositories/connectivity.dart';
import '../use_case.dart';

class GetConnectivityTypeStreamUseCase extends UseCase {
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Stream<ConnectivityType> call() => _connectivityRepository.statusStream;
}

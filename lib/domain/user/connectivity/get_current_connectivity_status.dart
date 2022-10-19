import '../../../dependency_locator.dart';
import '../../use_case.dart';
import 'connectivity.dart';
import 'connectivity_type.dart';

class GetCurrentConnectivityTypeUseCase extends UseCase {
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Future<ConnectivityType> call() => _connectivityRepository.currentType;
}

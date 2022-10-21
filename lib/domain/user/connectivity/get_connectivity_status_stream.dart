import '../../../dependency_locator.dart';
import '../../use_case.dart';
import 'connectivity.dart';
import 'connectivity_type.dart';

class GetConnectivityTypeStreamUseCase extends UseCase {
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Stream<ConnectivityType> call() => _connectivityRepository.statusStream;
}

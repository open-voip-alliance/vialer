import '../../../dependency_locator.dart';
import '../../metrics/metrics.dart';
import '../../use_case.dart';
import 'shared_contacts_repository.dart';

class DeleteSharedContactUseCase extends UseCase {
  late final _sharedContactsRepository =
      dependencyLocator<SharedContactsRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({required String? uuid}) {
    _metricsRepository.track('delete-shared-contact');

    return _sharedContactsRepository.deleteSharedContact(uuid);
  }
}

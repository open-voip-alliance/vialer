import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../data/repositories/colltacts/shared_contacts/shared_contacts_repository.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

class DeleteSharedContactUseCase extends UseCase {
  late final _sharedContactsRepository =
      dependencyLocator<SharedContactsRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({required String? uuid}) async {
    await _sharedContactsRepository.deleteSharedContact(uuid);

    _metricsRepository.track('shared-contact-deleted');
  }
}

import '../../../../data/repositories/colltacts/shared_contacts/shared_contacts_repository.dart';
import '../../../../dependency_locator.dart';
import '../../../../../data/repositories/metrics/metrics.dart';
import '../../use_case.dart';

class CreateSharedContactUseCase extends UseCase {
  late final _sharedContactsRepository =
      dependencyLocator<SharedContactsRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({
    required String? firstName,
    required String? lastName,
    required String? company,
    List<String> phoneNumbers = const [],
  }) async {
    await _sharedContactsRepository.createSharedContact(
      firstName,
      lastName,
      company,
      phoneNumbers,
    );

    _metricsRepository.track('shared-contact-created');
  }
}

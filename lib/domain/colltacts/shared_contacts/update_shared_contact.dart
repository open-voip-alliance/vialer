import '../../../dependency_locator.dart';
import '../../metrics/metrics.dart';
import '../../use_case.dart';
import 'shared_contacts_repository.dart';

class UpdateSharedContactUseCase extends UseCase {
  late final _sharedContactsRepository =
      dependencyLocator<SharedContactsRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({
    required String? uuid,
    required String? firstName,
    required String? lastName,
    required String? company,
    List<String> phoneNumbers = const [],
  }) {
    _metricsRepository.track('edit-shared-contact');

    return _sharedContactsRepository.updateSharedContact(
      uuid,
      firstName,
      lastName,
      company,
      phoneNumbers,
    );
  }
}

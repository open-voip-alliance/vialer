import '../../dependency_locator.dart';
import '../entities/availability.dart';
import '../entities/setting.dart';
import '../repositories/destination.dart';
import '../use_case.dart';
import 'change_setting.dart';

class GetLatestAvailabilityUseCase extends UseCase {
  final _destinationRepository = dependencyLocator<DestinationRepository>();
  final _changeSetting = ChangeSettingUseCase();

  Future<Availability?> call() async {
    final availability = await _destinationRepository.getLatestAvailability();

    await _changeSetting(
      setting: AvailabilitySetting(availability),
      remote: false,
    );

    return availability;
  }
}

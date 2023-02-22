import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../authentication/logout.dart';
import '../authentication/unauthorized_api_response.dart';
import '../call_records/client/import_historic_client_call_records.dart';
import '../call_records/client/purge_local_call_records.dart';
import '../metrics/identify_for_tracking.dart';
import '../onboarding/is_onboarded.dart';
import '../use_case.dart';
import '../user/settings/app_setting.dart';
import '../user/settings/setting_changed.dart';
import 'event_bus.dart';

/// Register any domain-level event listeners, this is separate to the app-level
/// event listeners that require the user interface to take action.
class RegisterDomainEventListenersUseCase extends UseCase with Loggable {
  final _eventBus = dependencyLocator<EventBusObserver>();
  final _logout = Logout();
  final _isOnboarded = IsOnboarded();
  final _importHistoricClientCalls = ImportHistoricClientCallRecordsUseCase();
  final _purgeLocalCallRecords = PurgeLocalCallRecordsUseCase();
  final _identifyForTracking = IdentifyForTrackingUseCase();

  void call() {
    _eventBus.on<UnauthorizedApiResponseEvent>((event) {
      if (!_isOnboarded()) return;

      logger.warning(
        'Logging unauthorized user out, code was: ${event.statusCode}.',
      );
      _logout();
    });

    _eventBus.onSettingChange<bool>(
      AppSetting.showClientCalls,
      (oldValue, newValue) {
        if (newValue == true) {
          _importHistoricClientCalls();
        } else {
          _purgeLocalCallRecords(reason: PurgeReason.disabled);
        }
      },
    );

    _eventBus.on<SettingChanged>((_) => _identifyForTracking());
  }
}

import 'dart:async';

import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../authentication/logout_on_unauthorized_response.dart';
import '../authentication/unauthorized_api_response.dart';
import '../call_records/client/import_historic_client_call_records.dart';
import '../call_records/client/purge_local_call_records.dart';
import '../metrics/identify_for_tracking.dart';
import '../use_case.dart';
import '../user/events/logged_in_user_was_refreshed.dart';
import '../user/handle_app_account_change.dart';
import '../user/settings/app_setting.dart';
import '../user/settings/setting_changed.dart';
import '../voipgrid/rate_limit_reached_event.dart';
import '../voipgrid/track_rate_limited_api_calls.dart';
import 'event_bus.dart';

/// Register any domain-level event listeners, this is separate to the app-level
/// event listeners that require the user interface to take action.
class RegisterDomainEventListenersUseCase extends UseCase with Loggable {
  final _eventBus = dependencyLocator<EventBusObserver>();
  final _importHistoricClientCalls = ImportHistoricClientCallRecordsUseCase();
  final _purgeLocalCallRecords = PurgeLocalCallRecordsUseCase();
  final _identifyForTracking = IdentifyForTrackingUseCase();
  final _logoutOnUnauthorizedResponse = LogoutOnUnauthorizedResponse();
  final _trackRateLimitedApiCalls = TrackRateLimitedApiCalls();
  final _handleAppAccountChange = HandleAppAccountChange();

  void call() {
    _eventBus
      ..on<UnauthorizedApiResponseEvent>(_logoutOnUnauthorizedResponse)
      ..on<RateLimitReachedEvent>(
        (event) => _trackRateLimitedApiCalls(event.url),
      )
      ..onSettingChange<bool>(
        AppSetting.showClientCalls,
        (oldValue, newValue) {
          if (newValue == true) {
            unawaited(_importHistoricClientCalls());
          } else {
            unawaited(_purgeLocalCallRecords(reason: PurgeReason.disabled));
          }
        },
      )
      ..on<SettingChangedEvent>((_) => unawaited(_identifyForTracking()))
      ..on<LoggedInUserWasRefreshed>(
        (event) {
          if (!event.isFirstTime) {
            unawaited(
              _handleAppAccountChange(
                previous: event.previous.appAccount,
                current: event.current.appAccount,
              ),
            );
          }
        },
      );
  }
}

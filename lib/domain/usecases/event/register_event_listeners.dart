import 'dart:async';

import '../../../data/API/authentication/unauthorized_api_response.dart';
import '../../../data/models/event/event_bus.dart';
import '../../../data/models/user/events/logged_in_user_was_refreshed.dart';
import '../../../data/models/user/settings/setting_changed.dart';
import '../../../data/models/voipgrid/rate_limit_reached_event.dart';
import '../../../dependency_locator.dart';
import '../../../presentation/util/loggable.dart';
import '../../usecases/metrics/identify_for_tracking.dart';
import '../authentication/logout_on_unauthorized_response.dart';
import '../use_case.dart';
import '../user/handle_app_account_change.dart';
import '../voipgrid/track_rate_limited_api_calls.dart';

/// Register any domain-level event listeners, this is separate to the app-level
/// event listeners that require the user interface to take action.
class RegisterDomainEventListenersUseCase extends UseCase with Loggable {
  final _eventBus = dependencyLocator<EventBusObserver>();
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

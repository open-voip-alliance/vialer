import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../events/event_bus.dart';
import '../events/unauthorized_api_response.dart';
import '../use_case.dart';
import 'get_is_authenticated.dart';
import 'logout.dart';

/// Register any domain-level event listeners, this is separate to the app-level
/// event listeners that require the user interface to take action.
class RegisterDomainEventListenersUseCase extends UseCase with Loggable {
  final _eventBus = dependencyLocator<EventBusObserver>();
  final _logout = LogoutUseCase();
  final _isAuthenticated = GetIsAuthenticatedUseCase();

  void call() {
    _eventBus.on<UnauthorizedApiResponseEvent>((event) async {
      final isAuthenticated = await _isAuthenticated();

      if (!isAuthenticated) return;

      logger.warning(
        'Logging unauthorized user out, code was: ${event.statusCode}.',
      );
      _logout();
    });
  }
}

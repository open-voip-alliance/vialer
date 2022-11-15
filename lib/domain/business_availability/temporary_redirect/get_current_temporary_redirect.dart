import '../../../../dependency_locator.dart';
import '../../event/event_bus.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../business_availability_repository.dart';
import 'temporary_redirect.dart';
import 'temporary_redirect_did_change_event.dart';

class GetCurrentTemporaryRedirect extends UseCase {
  late final _getUser = GetLoggedInUserUseCase();
  late final _businessAvailability =
      dependencyLocator<BusinessAvailabilityRepository>();
  late final _eventBus = dependencyLocator<EventBus>();

  Future<TemporaryRedirect?> call() async {
    final user = _getUser();

    if (!user.permissions.canUseTemporaryRedirect) {
      return null;
    }

    final redirect = await _businessAvailability.getCurrentTemporaryRedirect(
      user: user,
    );

    _eventBus.broadcast(TemporaryRedirectDidChangeEvent(current: redirect));

    return redirect;
  }
}

mixin TemporaryRedirectEventBroadcaster {
  Future<void> broadcast() async => GetCurrentTemporaryRedirect()();
}

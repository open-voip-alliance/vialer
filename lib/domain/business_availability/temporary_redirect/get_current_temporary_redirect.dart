import '../../../../dependency_locator.dart';
import '../../event/event_bus.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../../user/refresh/refresh_user.dart';
import '../../user/refresh/user_refresh_task.dart';
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

    final redirect = await _businessAvailability.getCurrentTemporaryRedirect(
      user: user,
    );

    _eventBus.broadcast(redirect.asEvent());

    return redirect;
  }
}

mixin TemporaryRedirectEventBroadcaster {
  Future<void> broadcast() async {
    await RefreshUser()(
      tasksToPerform: [UserRefreshTask.clientTemporaryRedirect],
    );

    final user = GetLoggedInUserUseCase()();

    dependencyLocator<EventBus>().broadcast(
      user.client.currentTemporaryRedirect.asEvent(),
    );
  }
}

extension on TemporaryRedirect? {
  TemporaryRedirectDidChangeEvent asEvent() => TemporaryRedirectDidChangeEvent(
        current: this,
      );
}

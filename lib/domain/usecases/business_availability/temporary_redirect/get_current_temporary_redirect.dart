import '../../../../../dependency_locator.dart';
import '../../../../data/models/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../../../data/models/business_availability/temporary_redirect/temporary_redirect_did_change_event.dart';
import '../../../../data/models/event/event_bus.dart';
import '../../../../data/models/user/refresh/user_refresh_task.dart';
import '../../../../data/repositories/business_availability/business_availability_repository.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../../user/refresh/refresh_user.dart';

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

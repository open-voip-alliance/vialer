import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/business_availability/temporary_redirect/change_current_temporary_redirect.dart';
import '../../../../../domain/business_availability/temporary_redirect/setup_temporary_redirect.dart';
import '../../../../../domain/business_availability/temporary_redirect/stop_current_temporary_redirect.dart';
import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect_did_change_event.dart';
import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect_exception.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/user/get_logged_in_user.dart';

import 'state.dart';
export 'state.dart';

class TemporaryRedirectCubit extends Cubit<TemporaryRedirectState> {
  late final _eventBus = dependencyLocator<EventBusObserver>();
  late final _startTemporaryRedirect = StartTemporaryRedirect();
  late final _changeCurrentTemporaryRedirect = ChangeCurrentTemporaryRedirect();
  late final _getUser = GetLoggedInUserUseCase();

  TemporaryRedirectCubit() : super(const TemporaryRedirectState.none([])) {
    _emitInitialState();

    _eventBus.on<TemporaryRedirectDidChangeEvent>((event) {
      _emitInitialState(event.current);
    });
  }

  void _emitInitialState([TemporaryRedirect? temporaryRedirect]) {
    final availableDestinations = _getUser()
        .client
        .voicemailAccounts
        .map(TemporaryRedirectDestination.voicemail);

    emit(
      temporaryRedirect != null
          ? TemporaryRedirectState.active(
              availableDestinations,
              temporaryRedirect,
            )
          : TemporaryRedirectState.none(availableDestinations),
    );
  }

  Future<void> stopTemporaryRedirect() => StopCurrentTemporaryRedirect()();

  Future<void> startOrUpdateCurrentTemporaryRedirect(
    TemporaryRedirectDestination destination,
    DateTime until,
  ) async =>
      state.map(
        none: (_) => destination.map(
          voicemail: (voicemail) => _startTemporaryRedirect(
            voicemailAccount: voicemail.voicemailAccount,
            endingAt: until,
          ),
          unknown: (_) => throw UnableToRedirectToUnknownDestination(),
        ),
        active: (state) => _changeCurrentTemporaryRedirect(
          temporaryRedirect: state.redirect.copyWith(
            destination: destination,
            endsAt: until,
          ),
        ),
      );
}

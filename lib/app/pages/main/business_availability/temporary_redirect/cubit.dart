import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/business_availability/temporary_redirect/change_current_temporary_redirect.dart';
import '../../../../../domain/business_availability/temporary_redirect/setup_temporary_redirect.dart';
import '../../../../../domain/business_availability/temporary_redirect/stop_current_temporary_redirect.dart';
import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect_did_change_event.dart';
import '../../../../../domain/event/event_bus.dart';
import 'state.dart';

class TemporaryRedirectCubit extends Cubit<TemporaryRedirectState> {
  late final _eventBus = dependencyLocator<EventBusObserver>();
  late final _startTemporaryRedirect = StartTemporaryRedirect();
  late final _changeCurrentTemporaryRedirect = ChangeCurrentTemporaryRedirect();

  TemporaryRedirectCubit() : super(const TemporaryRedirectState.none()) {
    _emitInitialState();

    _eventBus.on<TemporaryRedirectDidChangeEvent>((event) {
      _emitInitialState(event.current);
    });
  }

  void _emitInitialState([TemporaryRedirect? temporaryRedirect]) => emit(
        temporaryRedirect != null
            ? TemporaryRedirectState.active(temporaryRedirect)
            : const TemporaryRedirectState.none(),
      );

  Future<void> stopTemporaryRedirect() => StopCurrentTemporaryRedirect()();

  Future<void> startOrUpdateCurrentTemporaryRedirect(
    TemporaryRedirectDestination destination,
  ) async =>
      state.map(
        none: (_) => destination.map(
          voicemail: (voicemail) => _startTemporaryRedirect(
            voicemailAccount: voicemail.voicemailAccount,
          ),
        ),
        active: (state) => _changeCurrentTemporaryRedirect(
          temporaryRedirect: state.redirect.copyWith(destination: destination),
        ),
      );
}

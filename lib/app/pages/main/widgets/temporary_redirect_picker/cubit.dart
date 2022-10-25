import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect_did_change_event.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
import '../../../../../domain/voicemail/voicemail_account.dart';
import 'state.dart';

export 'state.dart';

class TemporaryRedirectPickerCubit extends Cubit<TemporaryRedirectPickerState> {
  late final _eventBus = dependencyLocator<EventBusObserver>();

  TemporaryRedirectPickerCubit(TemporaryRedirect? initialTemporaryRedirect)
      : super(_createState(initialTemporaryRedirect)) {
    _eventBus.on<TemporaryRedirectDidChangeEvent>((event) {
      emit(_createState(event.current));
    });
  }

  void changeCurrentDestination(TemporaryRedirectDestination destination) {
    final state = this.state;

    emit(state.copyWith(currentlySelectedDestination: destination));
  }

  static TemporaryRedirectPickerState _createState([
    TemporaryRedirect? temporaryRedirect,
  ]) {
    final user = GetLoggedInUserUseCase()();
    final voicemailAccounts = user.client != null
        ? user.client!.voicemailAccounts
        : <VoicemailAccount>[];
    final destinations =
        voicemailAccounts.map(TemporaryRedirectDestination.voicemail);

    return TemporaryRedirectPickerState(
      temporaryRedirect != null
          ? temporaryRedirect.destination
          : destinations.firstOrNull,
      destinations,
    );
  }
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/business_availability/temporary_redirect.dart';
import '../../../../../domain/voicemail/voicemail_account.dart';
import 'state.dart';

export 'state.dart';

class TemporaryRedirectPickerCubit extends Cubit<TemporaryRedirectPickerState> {
  TemporaryRedirectPickerCubit() : super(const LoadingDestinations()) {
    _emitInitialState();
  }

  Future<void> _emitInitialState() async {
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Get destinations from API
    // TODO: If the initial data can be retrieved syncly, put this logic
    // in the constructor and remove the
    // LoadingDestinations state class.
    const current = TemporaryRedirectDestination.voicemail(
      VoicemailAccount(
        id: '1',
        name: 'Voicemail One',
        description: 'The first voicemail',
      ),
    );
    const destinations = <TemporaryRedirectDestination>[
      current,
      TemporaryRedirectDestination.voicemail(
        VoicemailAccount(
          id: '2',
          name: 'Voicemail Two',
          description: 'The second voicemail',
        ),
      ),
      TemporaryRedirectDestination.voicemail(
        VoicemailAccount(
          id: '3',
          name: 'Voicemail Three',
          description: 'The third voicemail',
        ),
      ),
    ];
    emit(const LoadedDestinations(current, destinations));
  }

  void changeCurrentDestination(TemporaryRedirectDestination destination) {
    final state = this.state;

    if (state is! LoadedDestinations) return;

    emit(state.copyWith(currentDestination: destination));
  }

  Future<void> startRedirect() async {
    final state = this.state;
    if (state is! LoadedDestinations) return;

    // TODO: Replace
    print('Start redirect to ${state.currentDestination}');
  }
}

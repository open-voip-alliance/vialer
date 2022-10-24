import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/business_availability/get_current_temporary_redirect.dart';
import '../../../../../domain/business_availability/temporary_redirect.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
import '../../../../../domain/voicemail/voicemail_account.dart';
import 'state.dart';

export 'state.dart';

class TemporaryRedirectPickerCubit extends Cubit<TemporaryRedirectPickerState> {
  final _getCurrentTemporaryRedirect = GetCurrentTemporaryRedirect();
  final _getUser = GetLoggedInUserUseCase();

  TemporaryRedirectPickerCubit() : super(const LoadingDestinations()) {
    _emitInitialState();
  }

  Future<void> _emitInitialState() async {
    final current = await _getCurrentTemporaryRedirect();
    final user = _getUser();
    final voicemailAccounts = user.client != null
        ? user.client!.voicemailAccounts
        : <VoicemailAccount>[];

    final destinations = voicemailAccounts
        .where(
          (destination) =>
              destination.id != current?.destination.voicemailAccount.id,
        )
        .map(TemporaryRedirectDestination.voicemail);

    emit(LoadedDestinations(current?.destination, destinations));
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

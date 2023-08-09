import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/domain/user/events/logged_in_user_was_refreshed.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/authentication/user_was_logged_out.dart';
import '../../../../../domain/colltacts/shared_contacts/get_shared_contacts.dart';
import '../../../../../domain/colltacts/shared_contacts/shared_contact.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../widgets/caller/cubit.dart';
import 'state.dart';

export 'state.dart';

class SharedContactsCubit extends Cubit<SharedContactsState> {
  SharedContactsCubit(this._caller) : super(const LoadingSharedContacts()) {
    unawaited(loadSharedContacts());

    _eventBus
      ..on<UserWasLoggedOutEvent>((_) {
        emit(SharedContactsState.loading());
      })
      // TODO: Replace with the LoggedIn event when it is merged in
      ..on<LoggedInUserWasRefreshed>(
        (_) => loadSharedContacts(fullRefresh: false),
      );
  }

  final _eventBus = dependencyLocator<EventBusObserver>();
  final _getSharedContacts = GetSharedContactsUseCase();

  final CallerCubit _caller;

  List<SharedContact> _sharedContacts = [];

  bool get shouldShowSharedContacts =>
      (_sharedContacts.isNotEmpty || state is LoadingSharedContacts);

  Future<void> call(String destination) =>
      _caller.call(destination, origin: CallOrigin.sharedContacts);

  Future<void> loadSharedContacts({bool fullRefresh = false}) async {
    if (state is! SharedContactsLoaded) {
      emit(const SharedContactsState.loading());
    }

    _sharedContacts =
        await _getSharedContacts(forceSharedContactsRefresh: fullRefresh);

    emit(SharedContactsState.loaded(sharedContacts: _sharedContacts));
  }
}
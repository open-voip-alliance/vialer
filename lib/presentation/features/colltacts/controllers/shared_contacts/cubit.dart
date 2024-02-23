import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/API/authentication/user_logged_in.dart';
import '../../../../../../data/models/colltacts/colltact.dart';
import '../../../../../../data/models/colltacts/shared_contacts/shared_contact.dart';
import '../../../../../../data/models/event/event_bus.dart';
import '../../../../../../dependency_locator.dart';
import '../../../../../../domain/usecases/authentication/user_was_logged_out.dart';
import '../../../../../../domain/usecases/colltacts/shared_contacts/get_shared_contacts.dart';
import '../../../../shared/controllers/caller/cubit.dart';
import 'state.dart';

export 'state.dart';

class SharedContactsCubit extends Cubit<SharedContactsState> {
  SharedContactsCubit(this._caller) : super(const LoadingSharedContacts()) {
    unawaited(loadSharedContacts());

    _eventBus
      ..on<UserWasLoggedOutEvent>((_) {
        emit(SharedContactsState.loading());
      })
      ..on<UserLoggedIn>(
        (_) => loadSharedContacts(fullRefresh: false),
      );
  }

  final _eventBus = dependencyLocator<EventBusObserver>();
  final _getSharedContacts = dependencyLocator<GetSharedContactsUseCase>();

  final CallerCubit _caller;

  List<SharedContact> _sharedContacts = [];

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

  Colltact refreshColltactSharedContact(Colltact colltact) {
    if (state is SharedContactsLoaded && colltact is ColltactSharedContact) {
      final sharedContact =
          (state as SharedContactsLoaded).sharedContacts.firstWhereOrNull(
                (sharedContact) =>
                    sharedContact.id ==
                    (colltact as ColltactSharedContact).contact.id,
              );
      if (sharedContact != null)
        colltact = Colltact.sharedContact(sharedContact);
    }
    return colltact;
  }
}

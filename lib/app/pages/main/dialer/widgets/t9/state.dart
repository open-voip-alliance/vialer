import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../../domain/contacts/t9_contact.dart';

part 'state.freezed.dart';

@freezed
class T9ContactsState with _$T9ContactsState {
  const factory T9ContactsState.loading() = LoadingContacts;
  const factory T9ContactsState.loaded(
    List<Colltact> colltacts,
    List<T9Colltact> filteredContacts,
  ) = ContactsLoaded;
  const factory T9ContactsState.noPermission({required bool dontAskAgain}) =
      NoPermission;
}

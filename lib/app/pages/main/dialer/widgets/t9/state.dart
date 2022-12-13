import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../../domain/contacts/t9_contact.dart';

part 'state.freezed.dart';

@freezed
class T9ColltactsState with _$T9ColltactsState {
  const factory T9ContactsState.loading() = LoadingColltacts;
  const factory T9ContactsState.loaded(
    List<Colltact> colltacts,
    List<T9Colltact> filteredColltacts,
  ) = ContactsLoaded;
  const factory T9ContactsState.noPermission({required bool dontAskAgain}) =
      NoPermission;
}

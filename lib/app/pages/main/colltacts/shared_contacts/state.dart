import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../domain/colltacts/shared_contacts/shared_contact.dart';

part 'state.freezed.dart';

@freezed
class SharedContactsState with _$SharedContactsState {
  const factory SharedContactsState.loading() = LoadingSharedContacts;

  const factory SharedContactsState.loaded({
    required List<SharedContact> sharedContacts,
  }) = SharedContactsLoaded;
}

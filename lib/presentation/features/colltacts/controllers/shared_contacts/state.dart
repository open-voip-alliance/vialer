import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../data/models/colltacts/shared_contacts/shared_contact.dart';

part 'state.freezed.dart';

@freezed
class SharedContactsState with _$SharedContactsState {
  const factory SharedContactsState.loading() = LoadingSharedContacts;

  const factory SharedContactsState.loaded({
    required List<SharedContact> sharedContacts,
  }) = SharedContactsLoaded;
}

extension LoadedAndNotEmpty on SharedContactsState {
  bool get isLoadedWithNoEmptyList =>
      this is SharedContactsLoaded &&
      (this as SharedContactsLoaded).sharedContacts.isNotEmpty;
}

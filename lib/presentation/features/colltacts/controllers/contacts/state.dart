import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../../presentation/util/pigeon.dart';
import '../../../../../../data/models/colltacts/contact.dart';

part 'state.freezed.dart';

@freezed
class ContactsState with _$ContactsState {
  const factory ContactsState.loading() = LoadingContacts;

  const factory ContactsState.loaded({
    required Iterable<Contact> contacts,
    required ContactSort contactSort,
    required bool noContactPermission,
    required bool dontAskAgain,
  }) = ContactsLoaded;
}

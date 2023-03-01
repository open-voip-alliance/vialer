import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../app/util/pigeon.dart';
import '../../../../../domain/colltacts/contact.dart';

part 'state.freezed.dart';

@freezed
class ContactState with _$ContactState {
  const factory ContactState.loading() = LoadingContacts;

  const factory ContactState.loaded({
    required Iterable<Contact> contacts,
    required ContactSort contactSort,
    required bool noContactPermission,
    required bool dontAskAgain,
  }) = ContactsLoaded;
}

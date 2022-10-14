import 'package:equatable/equatable.dart';

import '../../../../../../app/util/pigeon.dart';
import '../../../../../domain/contacts/contact.dart';

abstract class ContactsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadingContacts extends ContactsState {}

class NoPermission extends ContactsState {
  final bool dontAskAgain;

  NoPermission({required this.dontAskAgain});

  @override
  List<Object?> get props => [dontAskAgain];
}

class ContactsLoaded extends ContactsState {
  final Iterable<Contact> contacts;
  final ContactSort contactSort;

  ContactsLoaded(this.contacts, this.contactSort);

  @override
  List<Object?> get props => [contacts];
}

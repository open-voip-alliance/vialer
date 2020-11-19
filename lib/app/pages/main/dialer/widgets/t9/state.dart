import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../../../domain/entities/contact.dart';
import '../../../../../../domain/entities/t9_contact.dart';

abstract class T9ContactsState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadingContacts extends T9ContactsState {}

class NoPermission extends T9ContactsState {
  final bool dontAskAgain;

  NoPermission({@required this.dontAskAgain});

  @override
  List<Object> get props => [dontAskAgain];
}

class ContactsLoaded extends T9ContactsState {
  final List<Contact> contacts;
  final List<T9Contact> filteredContacts;

  ContactsLoaded(this.contacts, this.filteredContacts);

  @override
  List<Object> get props => [contacts, filteredContacts];
}

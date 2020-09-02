import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../domain/entities/contact.dart';

abstract class ContactsState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadingContacts extends ContactsState {}

class NoPermission extends ContactsState {
  final bool dontAskAgain;

  NoPermission({@required this.dontAskAgain});

  @override
  List<Object> get props => [dontAskAgain];
}

class ContactsLoaded extends ContactsState {
  final Iterable<Contact> contacts;

  ContactsLoaded(this.contacts);

  @override
  List<Object> get props => [contacts];
}

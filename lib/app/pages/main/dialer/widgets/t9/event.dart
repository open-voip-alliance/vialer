import 'package:equatable/equatable.dart';

abstract class T9ContactsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadContacts extends T9ContactsEvent {}

class FilterT9Contacts extends T9ContactsEvent {
  final String input;

  FilterT9Contacts(this.input);

  @override
  List<Object?> get props => [input];
}

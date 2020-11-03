import 'dart:async';
import 'dart:io';

import 'package:diacritic/diacritic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartx/dartx.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../../domain/entities/permission.dart';
import '../../../../../../domain/entities/permission_status.dart';
import '../../../../../../domain/entities/t9_contact.dart';

import '../../../../../../domain/usecases/get_contacts.dart';
import '../../../../../../domain/usecases/get_permission_status.dart';

import 'event.dart';
import 'state.dart';

export 'state.dart';
export 'event.dart';

class T9ContactsBloc extends Bloc<T9ContactsEvent, T9ContactsState> {
  final _getContacts = GetContactsUseCase();
  final _getPermissionStatus = GetPermissionStatusUseCase();

  T9ContactsBloc() : super(LoadingContacts()) {
    add(LoadContacts());
  }

  @override
  Stream<T9ContactsState> mapEventToState(T9ContactsEvent event) async* {
    if (event is LoadContacts) {
      yield* _loadContactsIfAllowed();
    } else if (event is FilterT9Contacts) {
      yield* _filterContacts(event);
    }
  }

  @override
  Stream<Transition<T9ContactsEvent, T9ContactsState>> transformEvents(
    Stream<T9ContactsEvent> events,
    TransitionFunction<T9ContactsEvent, T9ContactsState> transitionFn,
  ) {
    // Only add a debounce to the filter event.
    final nonDebounceStream =
        events.where((event) => event is! FilterT9Contacts);

    final debounceStream = events
        .where((event) => event is FilterT9Contacts)
        .debounceTime(const Duration(milliseconds: 200));

    return super.transformEvents(
      MergeStream([nonDebounceStream, debounceStream]),
      transitionFn,
    );
  }

  Stream<T9ContactsState> _loadContactsIfAllowed() async* {
    final status = await _getPermissionStatus(permission: Permission.contacts);

    if (status == PermissionStatus.granted) {
      yield* _loadContacts();
    } else {
      yield NoPermission(
        dontAskAgain: status == PermissionStatus.permanentlyDenied ||
            (Platform.isIOS && status == PermissionStatus.denied),
      );
    }
  }

  Stream<T9ContactsState> _loadContacts() async* {
    if (state is NoPermission) return;

    if (state is! ContactsLoaded) {
      yield LoadingContacts();
    }

    yield ContactsLoaded(await _getContacts(), []);
  }

  Stream<T9ContactsState> _filterContacts(FilterT9Contacts event) async* {
    // Necessary for auto cast.
    final state = this.state;

    final input = event.input;

    if (state is NoPermission) return;

    if (state is ContactsLoaded) {
      if (input.isEmpty) {
        yield ContactsLoaded(state.contacts, []);
        return;
      }

      final regex = _getT9Regex(input);

      // Map each contact with multiple phone numbers to multiple t9 contacts
      // with a single phone number.
      final t9Contacts = state.contacts
          .map(
            (contact) => contact.phoneNumbers.map(
              (number) => T9Contact(
                name: contact.name,
                avatar: contact.avatar,
                relevantPhoneNumber: number,
              ),
            ),
          )
          .flatten()
          // Only keep those whose name or number matches the regex.
          .where(
            (contact) =>
                removeDiacritics(contact.name).contains(regex) ||
                contact.relevantPhoneNumber.value.contains(regex),
          )
          .toList();

      yield ContactsLoaded(state.contacts, t9Contacts);
    }
  }

  RegExp _getT9Regex(String input) {
    // Construct a regular expression that matches the digits (mapped to
    // characters) from the start of each word (aka first name and last name)
    // or digits everywhere in the phone number, ignoring white spaces.

    // For example, input 275 will match with regex:
    // (\b[abc][pqrs][jkl]|2[^0-9]*7[^0-9]*5[^0-9]*)

    final keyMap = {
      '1': '',
      '2': 'abc',
      '3': 'def',
      '4': 'ghi',
      '5': 'jkl',
      '6': 'mno',
      '7': 'pqrs',
      '8': 'tuv',
      '9': 'wxyz',
      '0': '',
    };

    // Ignore all characters except those allowed in a phone number.
    final inputPhoneNumber = input
        .replaceAll(RegExp(r'[^0-9]'), '')
        .replaceAllMapped(RegExp(r'.'), (m) => '${m[0]}[^0-9]*');

    // Ignore 0 and 1 for the name matching, they don't map to a character.
    var inputName = input.replaceAll(RegExp(r'[^2-9]'), '');
    if (inputName.isEmpty) {
      return RegExp('$inputPhoneNumber', caseSensitive: false);
    }

    inputName =
        inputName.replaceAllMapped(RegExp(r'.'), (m) => '[${keyMap[m[0]]}]');

    return RegExp('(\\b$inputName|$inputPhoneNumber)', caseSensitive: false);
  }
}

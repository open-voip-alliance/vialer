import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../../domain/call_records/item.dart';
import '../../../../../../domain/contacts/get_contacts.dart';
import '../../../../../../domain/contacts/t9_contact.dart';
import '../../../../../../domain/user/get_permission_status.dart';
import '../../../../../../domain/user/permissions/permission.dart';
import '../../../../../../domain/user/permissions/permission_status.dart';
import '../../../../../../domain/user_availability/colleagues/get_colleagues.dart';
import '../../../../../util/extensions.dart';
import 'event.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

class T9ContactsBloc extends Bloc<T9ContactsEvent, T9ContactsState> {
  final _getContacts = GetContactsUseCase();
  final _getColleagues = GetColleagues();
  final _getPermissionStatus = GetPermissionStatusUseCase();

  T9ContactsBloc() : super(const LoadingContacts()) {
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
    // ignore: deprecated_member_use
    TransitionFunction<T9ContactsEvent, T9ContactsState> transitionFn,
  ) {
    // Only add a debounce to the filter event.
    final nonDebounceStream =
        events.where((event) => event is! FilterT9Contacts);

    final debounceStream = events
        .where((event) => event is FilterT9Contacts)
        .debounceTime(const Duration(milliseconds: 500));

    // ignore: deprecated_member_use
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
      yield const LoadingContacts();
    }

    final contacts = await _getContacts(latest: false);
    final colleagues = await _getColleagues();

    final colltacts = [
      ...contacts.map(Colltact.contact),
      ...colleagues.map(Colltact.colleague),
    ];

    yield ContactsLoaded(colltacts, []);
  }

  Stream<T9ContactsState> _filterContacts(FilterT9Contacts event) async* {
    // Necessary for auto cast.
    final state = this.state;

    final input = event.input;

    if (state is NoPermission) return;

    if (state is ContactsLoaded) {
      if (input.isEmpty) {
        yield ContactsLoaded(state.colltacts, []);
        return;
      }

      final t9Colltacts = await compute(
        _filterContactsByRegularExpression,
        _FilterByRegularExpressionRequest(
          colltacts: state.colltacts,
          regex: _getT9Regex(input),
        ),
      );

      yield ContactsLoaded(state.colltacts, t9Contacts);
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

    // Ignore all characters except those allowed in a phone number. Also remove
    // the first 0 so we can properly match it against numbers with country
    // codes.
    final inputPhoneNumber = input
        .formatForPhoneNumberQuery()
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

/// Filters the list of contacts by a given T9 search, for a large amount of
/// contacts this can be computationally heavy so it is designed to be run
/// in an isolate.
Future<List<T9Colltact>> _filterContactsByRegularExpression(
  _FilterByRegularExpressionRequest request,
) async {
  // Map each contact with multiple phone numbers to multiple t9 contacts
  // with a single phone number.
  return request.colltacts
      .map(
        (colltact) => colltact.when(
          colleague: (colleague) => [
            T9Colltact(
              colltact: colltact,
              relevantPhoneNumber: Item(
                label: '',
                value: colleague.number ?? '',
              ),
            )
          ],
          contact: (contact) => contact.phoneNumbers.map(
            (number) => T9Colltact(
              colltact: colltact,
              relevantPhoneNumber: number,
            ),
          ),
        ),
      )
      .flatten()
      // Only keep those whose name or number matches the regex.
      .where(
        (t9) =>
            removeDiacritics(t9.colltact.name).contains(request.regex) ||
            t9.relevantPhoneNumber.value.contains(request.regex),
      )
      .distinct()
      .toList();
}

class _FilterByRegularExpressionRequest {
  final List<Colltact> colltacts;
  final RegExp regex;

  const _FilterByRegularExpressionRequest({
    required this.colltacts,
    required this.regex,
  });
}

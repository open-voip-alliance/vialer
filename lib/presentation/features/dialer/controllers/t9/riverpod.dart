import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vialer/presentation/features/dialer/controllers/t9/state.dart';
import 'package:vialer/presentation/util/extensions.dart';

import '../../../../../../data/models/call_records/item.dart';
import '../../../../../../data/models/colltacts/colltact.dart';
import '../../../../../../data/models/colltacts/t9_colltact.dart';
import '../../../../../../data/models/user/permissions/permission.dart';
import '../../../../../../data/models/user/permissions/permission_status.dart';
import '../../../../../../domain/usecases/colltacts/get_contacts.dart';
import '../../../../../../domain/usecases/colltacts/shared_contacts/get_shared_contacts.dart';
import '../../../../../../domain/usecases/relations/colleagues/get_cached_colleagues.dart';
import '../../../../../../domain/usecases/user/get_permission_status.dart';
import '../../../../../dependency_locator.dart';

part 'riverpod.g.dart';

@Riverpod(keepAlive: true)
class T9Colltacts extends _$T9Colltacts {
  final _getContacts = GetContactsUseCase();
  final _getColleagues = GetCachedColleagues();
  final _getSharedContacts = dependencyLocator<GetSharedContactsUseCase>();
  final _getPermissionStatus = GetPermissionStatusUseCase();

  @override
  T9ColltactsState build() {
    return T9ColltactsState.loading();
  }

  Future<void> loadColltactsIfAllowed() async {
    final status = await _getPermissionStatus(permission: Permission.contacts);

    if (status == PermissionStatus.granted) {
      _loadColltacts();
    } else {
      state = T9ColltactsState.noPermission(
        dontAskAgain: status == PermissionStatus.permanentlyDenied ||
            (Platform.isIOS && status == PermissionStatus.denied),
      );
    }
  }

  Future<void> _loadColltacts() async {
    if (state is NoPermission) return;

    if (state is! ColltactsLoaded) {
      state = T9ColltactsState.loading();
    }

    final contacts = await _getContacts(latest: false);
    final colleagues = await _getColleagues();
    final sharedContacts = await _getSharedContacts();

    state = T9ColltactsState.loaded(
      [
        ...contacts.map(Colltact.contact),
        ...colleagues.map(Colltact.colleague),
        ...sharedContacts.map(Colltact.sharedContact),
      ],
      [],
    );
  }

  Future<void> filter(String input) async {
    // Necessary for auto cast.
    final state = this.state;

    if (state is NoPermission) return;

    if (state is ColltactsLoaded) {
      if (input.isEmpty) {
        this.state = T9ColltactsState.loaded(
          state.colltacts,
          [],
        );
        return;
      }

      final t9Colltacts = await compute(
        _filterColltactsByRegularExpression,
        _FilterByRegularExpressionRequest(
          colltacts: state.colltacts,
          regex: _getT9Regex(input),
        ),
      );

      this.state = T9ColltactsState.loaded(
        state.colltacts,
        t9Colltacts,
      );
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
        .replaceAll(RegExp('[^0-9]'), '')
        .replaceAllMapped(RegExp('.'), (m) => '${m[0]}[^0-9]*');

    // Ignore 0 and 1 for the name matching, they don't map to a character.
    var inputName = input.replaceAll(RegExp('[^2-9]'), '');
    if (inputName.isEmpty) {
      return RegExp(inputPhoneNumber, caseSensitive: false);
    }

    inputName =
        inputName.replaceAllMapped(RegExp('.'), (m) => '[${keyMap[m[0]]}]');

    return RegExp('(\\b$inputName|$inputPhoneNumber)', caseSensitive: false);
  }
}

/// Filters the list of colltacts by a given T9 search, for a large amount of
/// colltacts this can be computationally heavy so it is designed to be run
/// in an isolate.
Future<List<T9Colltact>> _filterColltactsByRegularExpression(
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
            ),
          ],
          contact: (contact) => contact.phoneNumbers.map(
            (number) => T9Colltact(
              colltact: colltact,
              relevantPhoneNumber: number,
            ),
          ),
          sharedContact: (sharedContact) => sharedContact.phoneNumbers.map(
            (number) => T9Colltact(
              colltact: colltact,
              relevantPhoneNumber: Item(
                label: '',
                value: number.phoneNumberFlat,
              ),
            ),
          ),
        ),
      )
      .flatten()
      // Only keep those whose name or number matches the regex.
      .where(
        (t9) =>
            t9.nameForT9Search.contains(request.regex) ||
            t9.relevantPhoneNumber.value.contains(request.regex),
      )
      .distinct()
      .toList();
}

class _FilterByRegularExpressionRequest {
  const _FilterByRegularExpressionRequest({
    required this.colltacts,
    required this.regex,
  });

  final List<Colltact> colltacts;
  final RegExp regex;
}

extension on T9Colltact {
  String get nameForT9Search => removeDiacritics(colltact.name).replaceAll(
        // Removing any of the characters a user can't input into the dialer or
        // that doesn't have a valid T9 mapping.
        RegExp('[^a-zA-Z0-9#+*]'),
        '',
      );
}

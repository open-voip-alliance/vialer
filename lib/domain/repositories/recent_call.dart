import 'package:libphonenumber/libphonenumber.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:timezone/timezone.dart';
import 'package:dartx/dartx.dart';

import 'db/database.dart';
import 'services/voipgrid.dart';

import '../entities/call.dart';
import '../entities/call_with_contact.dart';
import '../entities/contact.dart';
import '../entities/permission.dart';
import '../entities/permission_status.dart';

import 'permission.dart';
import 'contact.dart';
import 'auth.dart';

class RecentCallRepository {
  final VoipgridService _service;
  final Database _database;
  final ContactRepository _contactRepository;
  final PermissionRepository _permissionRepository;
  final AuthRepository _authRepository;

  RecentCallRepository(
    this._service,
    this._database,
    this._contactRepository,
    this._permissionRepository,
    this._authRepository,
  );

  Logger __logger;

  Logger get _logger => __logger ??= Logger('@$runtimeType');

  final _daysPerPage = 28;
  int _cacheStartPage;

  Future<List<CallWithContact>> getRecentCalls({@required int page}) async {
    final today = DateTime.now().add(Duration(days: 1));
    final fromUtc = today
        .subtract(
          Duration(days: _daysPerPage * (page + 1)),
        )
        .toUtc();
    final toUtc = today
        .subtract(
          Duration(days: _daysPerPage * page),
        )
        .toUtc();

    var calls = <Call>[];

    _logger.info(
      'Fetching recent calls between: '
      '${toUtc.toIso8601String()} and ${fromUtc.toIso8601String()}',
    );

    // Never get from cache for the first page, and then only
    // from when we're sure there's nothing remote.
    if (page != 0 && page >= (_cacheStartPage ?? 0)) {
      calls = await _database.getCalls(from: fromUtc, to: toUtc);
      _logger.info('Amount of calls from cache: ${calls.length}');
    }

    if (calls.isEmpty) {
      _logger.info('None cached, request more via API');
      final response = await _service.getPersonalCalls(
        from: fromUtc.toIso8601String(),
        to: toUtc.toIso8601String(),
      );

      final objects = response.body['objects'] as List<dynamic> ?? [];

      if (objects.isNotEmpty) {
        calls = objects
            .map((obj) => Call.fromJson(obj as Map<String, dynamic>))
            .map(
              (c) => c.copyWith(
                // The wrapper is needed so that it's a normal
                // DateTime and not a TZDateTime, because we want to call
                // the DateTime.toLocal method, not TZDateTime.toLocal, because
                // the latter uses the location set with `setLocation`, which
                // we can't use because we can't get the current time zone
                // automatically, but DateTime.toLocal _will_ convert it to the
                // correct current time zone.
                date: DateTime.fromMillisecondsSinceEpoch(
                  TZDateTime.from(
                    c.date,
                    getLocation('Europe/Amsterdam'),
                  ).millisecondsSinceEpoch,
                  isUtc: true,
                ),
              ),
            )
            .toList();

        final mostRecentCall = await _database.getMostRecentCall();
        if (mostRecentCall != null &&
            calls.any((c) => c.id == mostRecentCall.id)) {
          // If the response contains the most recent call we got, we can
          // continue from cache.
          _cacheStartPage = page;
        }

        _logger.info('Amount of calls from request: ${calls.length}');
        _database.insertCalls(calls);
      }
    }

    final canAccessContacts =
        await _permissionRepository.getPermissionStatus(Permission.contacts) ==
            PermissionStatus.granted;

    final contacts = canAccessContacts
        ? await _contactRepository.getContacts()
        : <Contact>[];

    Future<String> normalizeNumber(String number) async => number.length > 3
        ? await PhoneNumberUtil.normalizePhoneNumber(
            phoneNumber: number,
            // TODO: Temporary fix. Preferably we'd could pass a prefix
            // directly and have another method that fetches the prefix from the
            // outgoingCli (although that it's _too_ complicated), or we need
            // to map  all prefixes against two-letter ISO country codes and
            // pass that.
            isoCode: _authRepository.currentUser.outgoingCli.startsWith('+31')
                ? 'NL'
                : 'DE',
          ).catchError((_) => null)
        : number;

    // Map phone numbers by contact.
    final phoneNumbersByContact = Map.fromEntries(
      await Future.wait(
        contacts.map(
          (contact) async => MapEntry(
            contact,
            await Future.wait(
              contact.phoneNumbers
                  .map((phoneNumber) => normalizeNumber(phoneNumber.value))
                  .toList(),
            ),
          ),
        ),
      ),
    );

    final normalizedCalls = await Future.wait(
      calls.map(
        (c) async => c.copyWith(
          destinationNumber:
              c.isOutbound ? await normalizeNumber(c.destinationNumber) : null,
          callerNumber:
              c.isInbound ? await normalizeNumber(c.callerNumber) : null,
        ),
      ),
    );

    _logger.info('Mapping calls to contacts');
    return calls
        .map(
          (call) => call.withContact(
            phoneNumbersByContact.entries.firstOrNullWhere((entry) {
              final normalizedCall = normalizedCalls.firstOrNullWhere(
                (normalizedCall) => normalizedCall.id == call.id,
              );

              if (normalizedCall == null) {
                return false;
              }

              final numbers = entry.value;

              final relevantCallNumber = normalizedCall.isOutbound
                  ? normalizedCall.destinationNumber
                  : normalizedCall.callerNumber;

              return numbers.contains(relevantCallNumber);
            })?.key, // The contact.
          ),
        )
        .toList();
  }
}

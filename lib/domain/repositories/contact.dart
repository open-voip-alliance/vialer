import 'dart:convert';
import 'dart:io';

import 'package:contacts_service/contacts_service.dart' hide Contact;
import 'package:dartx/dartx.dart';
import 'package:fast_contacts/fast_contacts.dart' as fast_contacts;
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/util/loggable.dart';
import '../entities/contact.dart';
import 'mappers/contact.dart';

class ContactRepository with Loggable {
  var _memoryCache = <Contact>[];

  static var _isContactIsolateRunning = false;
  static var _isAvatarIsolateRunning = false;

  Future<List<Contact>> getContacts({
    bool onlyFromCache = false,
  }) async {
    if (_memoryCache.isNotEmpty && onlyFromCache) {
      return _memoryCache;
    }

    final isFirstLoad = !(await _hasItemsInCache);

    // If we're only loading from the cache and it's the first load (so there's
    // no data) then there is nothing to fetch and we can just return an empty
    // list.
    if (isFirstLoad && onlyFromCache) return _memoryCache;

    if (!onlyFromCache) {
      // If this is the first time the user loads contacts we're going to wait
      // until the cache file has been written to before returning.
      if (isFirstLoad) {
        await _cacheContactsLocally();
      } else {
        _cacheContactsLocally();
      }
    }

    _memoryCache = await _readContactsFromFileCache();

    if (!onlyFromCache) {
      _cacheAvatarsLocally(_memoryCache);
    }

    return _memoryCache.toList(growable: false);
  }

  /// Reads the contacts from the file based cache.
  Future<List<Contact>> _readContactsFromFileCache() async => contactsCacheFile
      .then((file) => file.readAsString())
      .then((json) => (jsonDecode(json) as List)
          .map((e) => Contact.fromJson(e as Map<String, dynamic>))
          .toList());

  Future<bool> get _hasItemsInCache async {
    final cacheFile = await contactsCacheFile;
    final exists = await cacheFile.exists();

    if (!exists) return false;

    final stats = await cacheFile.stat();

    return stats.size > 0;
  }

  /// Spawns an isolate to import avatars for all known contacts and store
  /// them in a local directory.
  ///
  /// Fetching avatars is very performance intensive which is why this is exists
  /// and is done off the main-thread.
  Future<void> _cacheAvatarsLocally(
    List<Contact> domainContacts,
  ) async {
    if (_isAvatarIsolateRunning) {
      logger.info('Skipping avatar import as it is already running.');
      return;
    }

    _isAvatarIsolateRunning = true;

    return flutterCompute(
      _isolateCacheAllAvatars,
      domainContacts
          .filter((element) => element.identifier != null)
          .map((contact) => contact.identifier!)
          .shuffled(),
    ).onError((error, stackTrace) {
      _isAvatarIsolateRunning = false;
      logger.warning('Avatar import isolate exited with error: $error');
    }).whenComplete(() {
      _isAvatarIsolateRunning = false;
    });
  }

  /// Spawns an isolate to read the contacts database, serialize them and store
  /// them in a local file.
  ///
  /// Performance is heavily impacted when users have thousands of contacts
  /// so this optimizes that.
  Future<void> _cacheContactsLocally() async {
    if (_isContactIsolateRunning) {
      logger.info('Skipping contact import as it is already running.');
      return;
    }

    _isContactIsolateRunning = true;

    return flutterCompute(
      _isolateCacheAllContacts,
      <String>[],
    ).onError((error, stackTrace) {
      _isContactIsolateRunning = false;
      logger.warning('Contact import isolate exited with error: $error');
    }).whenComplete(() {
      _isContactIsolateRunning = false;
    });
  }

  /// Retrieve a mapping between a phone number and a contact, this allows for
  /// optimized look-up of contacts.
  Future<Map<String, Contact>> getContactPhoneNumberMap() async {
    final contacts = await getContacts(onlyFromCache: true);
    final map = <String, Contact>{};

    for (final contact in contacts) {
      for (final item in contact.phoneNumbers) {
        final phoneNumber = item.value;
        map[phoneNumber.replaceAll(' ', '')] = contact;

        // Most contacts format numbers with country codes to
        // e.g. +31 6 4....
        // So we will replace the first item with a 0 to match with
        // non-country code phone numbers.
        final split = item.value.split(' ');

        if (split.length > 1) {
          split[0] = '0';
          map[split.join()] = contact;
        }
      }
    }

    return map;
  }

  /// Clean-up the contacts caches, this must always be performed if we don't
  /// have contact permissions.
  Future<void> cleanUp() async {
    _memoryCache = [];

    final cacheFiles = [
      await contactsCacheFile,
      await avatarDirectory,
    ];

    for (final file in cacheFiles) {
      if (await file.exists()) {
        file.delete(recursive: true);
      }
    }
  }
}

extension on Iterable<Contact> {
  Iterable<Contact> filterHasPhoneNumber({
    bool applyWhen = true,
  }) =>
      applyWhen ? where((contact) => contact.phoneNumbers.isNotEmpty) : this;
}

/// The time that we will keep avatars before checking for them again. A user
/// updating an avatar won't see changes until at least this time.
const avatarTtl = Duration(minutes: 5);

Future<Directory> get avatarDirectory async {
  final documentPath = (await getApplicationDocumentsDirectory()).path;
  final directory = Directory('$documentPath/avatar_cache');
  await directory.create();
  return directory;
}

/// Performs an import of all the user's contacts into a local file
/// in JSON format.
///
/// Designed to be run in an ISOLATE.
@pragma('vm:entry-point')
Future<void> _isolateCacheAllContacts(List<String> args) async {
  final avatarCacheDirectory = await avatarDirectory;
  final cacheFile = await contactsCacheFile;

  final contacts = (await ContactsService.getContacts(
    withThumbnails: false,
    photoHighResolution: false,
  ).then(
    (contacts) => contacts.toDomainEntities(
      avatarCacheDirectory: avatarCacheDirectory,
    ),
  ))
      .filterHasPhoneNumber()
      .toList(growable: false);

  final json = jsonEncode(contacts);

  await cacheFile.writeAsString(json, flush: true);
}

/// Iterates through an entire list of contact identifiers and caches them to a
/// local file.
///
/// Designed to be run in an ISOLATE.
@pragma('vm:entry-point')
Future<void> _isolateCacheAllAvatars(List<String> contactIdentifiers) async {
  for (final identifier in contactIdentifiers) {
    final file = File(createAvatarPath(
      directory: await avatarDirectory,
      identifier: identifier,
    ));
    final isStale = (await file.exists())
        ? file.lastModifiedSync().isBefore(DateTime.now().subtract(avatarTtl))
        : true;

    if (!isStale) continue;

    final image = await fast_contacts.FastContacts.getContactImage(
      identifier,
    );

    if (image == null) continue;

    file.writeAsBytes(List<int>.from(image));
  }

  await _cleanUpUnusedAvatars();
}

/// We will clean up any files that haven't been cached recently to make sure
/// we aren't keeping old data around.
Future<void> _cleanUpUnusedAvatars() async {
  final directory = await avatarDirectory;
  final deleteBefore = DateTime.now().subtract(const Duration(days: 7));

  for (final fileSystemEntity in directory.listSync()) {
    final file = File(fileSystemEntity.path);

    if (!(await file.exists())) continue;

    final lastModified = await file.lastModified();

    if (lastModified.isAfter(deleteBefore)) continue;

    fileSystemEntity.delete();
  }
}

Future<File> get contactsCacheFile async {
  final directory = (await getApplicationDocumentsDirectory()).path;
  return File('$directory/contacts_cache.json');
}

String createAvatarPath({
  required Directory directory,
  required String identifier,
}) {
  return '${directory.path}/$identifier.jpg';
}

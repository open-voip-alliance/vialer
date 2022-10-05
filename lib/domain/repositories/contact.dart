import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/util/loggable.dart';
import '../../app/util/pigeon.dart';
import '../../app/util/single_task.dart';
import '../entities/contact.dart';
import '../entities/item.dart';

class ContactRepository with Loggable {
  var _memoryCache = <Contact>[];

  Future<List<Contact>> getContacts({
    bool latest = false,
  }) async {
    final import = _importContactsIntoLocalCaches();

    // If the latest data has been requested, we are going to wait for the
    // import to be completed before returning any records.
    if (latest) return await import;

    // We will then check our two caches to see if there is any data there,
    // if we have then we will return directly from the caches.
    if (_isMemoryCachePopulated) return _memoryCache;

    // If there is no cached data then we have no choice but to wait for
    // the import.
    return await import;
  }

  /// Performs the performance and time consuming task of importing contacts
  /// from the native OS database, into a memory-based cache that we can access
  /// much more quickly.
  ///
  /// This will also begin the import of avatars, this can be an extremely
  /// long running task so we will never wait for this to complete.
  ///
  /// Only one instance of contact importing and one instance of avatar
  /// importing will be running simultaneously regardless of how many times
  /// this method is called.
  Future<List<Contact>> _importContactsIntoLocalCaches() async {
    final contactImporter = Contacts();
    final avatarCacheDirectory = await _avatarCacheDirectory;

    await SingleInstanceTask.named('Contact Import').run(
      () async {
        _memoryCache = (await contactImporter.fetchContacts())
            .toDomainContacts(avatarCacheDirectory)
            .toList(growable: false);
      },
    );

    SingleInstanceTask.named('Avatar Import').run(
      () => contactImporter.importContactAvatars(avatarCacheDirectory.path),
    );

    return _memoryCache;
  }

  bool get _isMemoryCachePopulated => _memoryCache.isNotEmpty;

  /// Purges all cached contact data, this must be performed in the event
  /// that the app should no longer have access to contacts. This can be due
  /// to permissions being revoked, the user logging out etc.
  ///
  /// If this isn't called, the user will potentially still see contact data
  /// in the app even if we don't have access to it.
  Future<void> cleanUp() async {
    _memoryCache.clear();

    final cacheFiles = [
      await _avatarCacheDirectory,
    ];

    for (final file in cacheFiles) {
      if (await file.exists()) {
        file.delete(recursive: true);
      }
    }
  }

  /// Avatars are cached as individual files with a format of
  /// `avatar_cache/12342.jpg` for Android
  /// or `avatar_cache/1996d240-0d5f-4b60-9630-42eb4c71fa29.jpg` for iOS. This
  /// is due to the way that each OS stores their identifiers, UUID for iOS
  /// but a regular int for Android.
  ///
  /// This provides the directory that all these cached avatar files will be
  /// stored.
  Future<Directory> get _avatarCacheDirectory async {
    final documentPath = (await getApplicationDocumentsDirectory()).path;
    final directory = Directory('$documentPath/avatar_cache');
    await directory.create();
    return directory;
  }
}

extension on List<PigeonContact?> {
  List<Contact> toDomainContacts(Directory avatarDirectory) => filterNotNull()
      .map((nativeContact) => nativeContact.toDomainContact(avatarDirectory))
      .toList(growable: false);
}

extension on PigeonContact {
  Contact toDomainContact(Directory avatarDirectory) => Contact(
        givenName: givenName,
        middleName: middleName,
        familyName: familyName,
        chosenName: chosenName,
        phoneNumbers: phoneNumbers.toDomainItems(),
        emails: emails.toDomainItems(),
        identifier: identifier,
        company: company,
        avatarPath: '${avatarDirectory.path}/$identifier.jpg',
      );
}

extension on List<PigeonContactItem?> {
  List<Item> toDomainItems() => filterNotNull()
      .filter((nativeItem) => nativeItem.value?.isNotNullOrBlank == true)
      .map(
        (nativeItem) => Item(
          label: nativeItem.label ?? '',
          value: nativeItem.value!,
        ),
      )
      .toList(growable: false);
}

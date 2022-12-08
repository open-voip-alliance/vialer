import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/util/loggable.dart';
import '../../app/util/pigeon.dart';
import '../../app/util/synchronized_task.dart';
import 'contact.dart';

class ContactRepository with Loggable {
  var _memoryCache = <Contact>[];

  Future<List<Contact>> getContacts({
    bool latest = false,
  }) async {
    final import = _importContactsIntoLocalCaches();

    // If the latest data has been requested, we are going to wait for the
    // import to be completed before returning any records.
    if (latest) {
      return await import;
    }

    // We will then check our two caches to see if there is any data there,
    // if we have then we will return directly from the caches.
    if (_isMemoryCachePopulated) {
      return _memoryCache;
    } else if (await _isFileCachePopulated) {
      return _readContactsFromFileCache();
    }

    // If there is no cached data then we have no choice but to wait for
    // the import.
    return await import;
  }

  /// Performs the performance and time consuming task of importing contacts
  /// from the native OS database, into a local cache (both memory and
  /// file-based) that we can access much more quickly.
  ///
  /// This will also begin the import of avatars, this can be an extremely
  /// long running task so we will never wait for this to complete.
  ///
  /// Only one instance of contact importing and one instance of avatar
  /// importing will be running simultaneously regardless of how many times
  /// this method is called.
  Future<List<Contact>> _importContactsIntoLocalCaches() async {
    final contactImporter = Contacts();
    final cachePath = (await _contactsCacheFile).path;
    final avatarCacheDirectory = (await _avatarCacheDirectory).path;

    await SynchronizedTask.named('Contact Import').run(
      () => contactImporter.importContacts(cachePath),
    );

    SynchronizedTask.named('Avatar Import').run(
      () => contactImporter.importContactAvatars(avatarCacheDirectory),
    );

    return _memoryCache = await _readContactsFromFileCache();
  }

  bool get _isMemoryCachePopulated => _memoryCache.isNotEmpty;

  /// Returns [TRUE] when the file cache has any data in it at all, this could
  /// be an empty contact list.
  Future<bool> get _isFileCachePopulated async {
    final cacheFile = await _contactsCacheFile;
    final exists = await cacheFile.exists();

    if (!exists) return false;

    final stats = await cacheFile.stat();

    if (stats.type == FileSystemEntityType.notFound) return false;

    // We're just going to check the file has more than an empty array in it.
    return stats.size > 5;
  }

  Future<List<Contact>> _readContactsFromFileCache() async {
    final file = await _contactsCacheFile;

    if (!(await file.exists())) {
      return [];
    }

    final json = await file.readAsString();

    return (jsonDecode(json) as List)
        .map((e) => Contact.fromJson(e as Map<String, dynamic>))
        .attachAvatarPaths(await _avatarCacheDirectory)
        .toList(growable: false);
  }

  /// Purges all cached contact data, this must be performed in the event
  /// that the app should no longer have access to contacts. This can be due
  /// to permissions being revoked, the user logging out etc.
  ///
  /// If this isn't called, the user will potentially still see contact data
  /// in the app even if we don't have access to it.
  Future<void> cleanUp() async {
    _memoryCache.clear();

    final cacheFiles = [
      await _contactsCacheFile,
      await _avatarCacheDirectory,
    ];

    for (final file in cacheFiles) {
      if (await file.exists()) {
        file.delete(recursive: true);
      }
    }
  }

  /// Contacts are cached into a single `.json` file, this is the path to
  /// that specific file.
  Future<File> get _contactsCacheFile async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    return File('$directory/contacts_cache.json');
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

extension on Iterable<Contact> {
  Iterable<Contact> attachAvatarPaths(Directory avatarPath) => filter(
        (contact) => contact.identifier.isNotNullOrBlank,
      ).map(
        (contact) => contact.copyWith(
          avatarPath: '${avatarPath.path}/${contact.identifier}.jpg',
        ),
      );
}

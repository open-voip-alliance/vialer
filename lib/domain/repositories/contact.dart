import 'dart:io';

import 'package:contacts_service/contacts_service.dart' hide Contact;
import 'package:dartx/dartx.dart';
import 'package:fast_contacts/fast_contacts.dart' as fast_contacts;
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:path_provider/path_provider.dart';

import '../entities/contact.dart';
import 'mappers/contact.dart';

class ContactRepository {
  Future<List<Contact>> getContacts({
    bool onlyWithPhoneNumber = true,
  }) async {
    final avatarCacheDirectory = await avatarDirectory;

    final contacts = await ContactsService.getContacts(
      withThumbnails: false,
      photoHighResolution: false,
    ).then(
      (contacts) => contacts.toDomainEntities(
        avatarCacheDirectory: avatarCacheDirectory,
      ),
    );

    _cacheAvatarsLocally(contacts);

    return contacts
        .filterHasPhoneNumber(applyWhen: onlyWithPhoneNumber)
        .toList(growable: false);
  }

  Future<void> _cacheAvatarsLocally(
    Iterable<Contact> domainContacts,
  ) async =>
      FlutterIsolate.spawn(
        _cacheAvatarsToLocalFiles,
        domainContacts
            .filter((element) => element.identifier != null)
            .map((contact) => contact.identifier!)
            .toList(),
      );

  Future<Contact?> getContactByPhoneNumber(String number) async {
    final avatarCacheDirectory = await avatarDirectory;

    return ContactsService.getContactsForPhone(
      number,
      withThumbnails: false,
      photoHighResolution: false,
    ).then(
      (contacts) => contacts.firstOrNull?.toDomainEntity(
        avatarCacheDirectory: avatarCacheDirectory,
      ),
    );
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

String createAvatarPath({
  required Directory directory,
  required String identifier,
}) {
  return '${directory.path}/$identifier.jpg';
}

/// Iterates through an entire list of contact identifiers and caches them to a
/// local file. This is for performance reasons while rendering them.
Future<void> _cacheAvatarsToLocalFiles(List<String> contactIdentifiers) async {
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

  _cleanUpUnusedAvatars();
}

/// We will clean up any files that haven't been cached recently to make sure
/// we aren't keeping old data around.
Future<void> _cleanUpUnusedAvatars() async {
  final directory = await avatarDirectory;
  final deleteBefore = DateTime.now().subtract(const Duration(days: 7));

  for (final fileSystemEntity in directory.listSync()) {
    final file = File(fileSystemEntity.path);

    if (file.existsSync()) {
      if (file.lastModifiedSync().isBefore(deleteBefore)) {
        fileSystemEntity.delete();
      }
    }
  }
}

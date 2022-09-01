import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:dartx/dartx.dart';

import '../../entities/contact.dart' as domain;
import '../contact.dart';
import '../mappers/item.dart';
import 'item.dart';

extension ContactMapper on Contact {
  Future<domain.Contact> toDomainEntity({
    required Directory avatarCacheDirectory,
  }) async {
    final avatarPath = createAvatarPath(
      directory: avatarCacheDirectory,
      identifier: identifier!,
    );

    return domain.Contact(
      givenName: givenName,
      middleName: middleName,
      familyName: familyName,
      chosenName: displayName,
      avatarPath: avatarPath,
      phoneNumbers:
          phones?.toDomainEntities().distinct().toList(growable: false) ?? [],
      emails: emails?.toDomainEntities().toList(growable: false) ?? [],
      identifier: identifier,
      company: company,
    );
  }
}

extension ContactIterableMapper on Iterable<Contact> {
  Future<Iterable<domain.Contact>> toDomainEntities({
    required Directory avatarCacheDirectory,
  }) async =>
      Future.wait(
        map(
          (i) => i.toDomainEntity(
            avatarCacheDirectory: avatarCacheDirectory,
          ),
        ),
      );
}

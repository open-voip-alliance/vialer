import 'dart:async';

import '../../dependency_locator.dart';
import '../use_case.dart';
import '../user/permissions/no_permission.dart';
import '../user/permissions/permission.dart';
import '../user/permissions/permission_repository.dart';
import '../user/permissions/permission_status.dart';
import 'contact.dart';
import 'contact_repository.dart';

class GetContactsUseCase extends UseCase {
  final _contactsRepository = dependencyLocator<ContactRepository>();
  final _permissionRepository = dependencyLocator<PermissionRepository>();

  Future<List<Contact>> call({
    bool latest = true,
  }) async {
    final status = await _permissionRepository.getPermissionStatus(
      Permission.contacts,
    );

    if (status != PermissionStatus.granted) {
      _contactsRepository.cleanUp();
      throw NoPermissionException();
    }

    final contacts = await _contactsRepository.getContacts();

    return contacts;
  }
}

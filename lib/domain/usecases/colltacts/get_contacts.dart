import 'dart:async';

import '../../../data/models/colltacts/contact.dart';
import '../../../data/models/user/permissions/no_permission.dart';
import '../../../data/models/user/permissions/permission.dart';
import '../../../data/models/user/permissions/permission_status.dart';
import '../../../data/repositories/colltacts/contact_repository.dart';
import '../../../data/repositories/user/permissions/permission_repository.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

class GetContactsUseCase extends UseCase {
  final _contactRepository = dependencyLocator<ContactRepository>();
  final _permissionRepository = dependencyLocator<PermissionRepository>();

  Future<List<Contact>> call({
    bool latest = true,
  }) async {
    final status = await _permissionRepository.getPermissionStatus(
      Permission.contacts,
    );

    if (status != PermissionStatus.granted) {
      unawaited(_contactRepository.cleanUp());
      throw NoPermissionException();
    }

    final contacts = await _contactRepository.getContacts();

    return contacts;
  }
}

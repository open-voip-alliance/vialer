import 'dart:async';

import '../../dependency_locator.dart';
import '../entities/contact.dart';
import '../entities/exceptions/no_permission.dart';
import '../entities/permission.dart';
import '../entities/permission_status.dart';
import '../repositories/contact.dart';
import '../repositories/permission.dart';
import '../use_case.dart';

class GetContactsUseCase extends UseCase {
  final _contactsRepository = dependencyLocator<ContactRepository>();
  final _permissionRepository = dependencyLocator<PermissionRepository>();

  Future<List<Contact>> call() async {
    final status = await _permissionRepository.getPermissionStatus(
      Permission.contacts,
    );

    if (status != PermissionStatus.granted) {
      throw NoPermissionException();
    } else {
      return await _contactsRepository.getContacts();
    }
  }
}

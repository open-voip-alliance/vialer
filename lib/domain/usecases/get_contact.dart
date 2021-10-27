import 'dart:async';

import '../../dependency_locator.dart';
import '../entities/contact.dart';
import '../entities/permission.dart';
import '../entities/permission_status.dart';
import '../repositories/contact.dart';
import '../repositories/permission.dart';
import '../use_case.dart';

class GetContactUseCase extends UseCase {
  final _contactsRepository = dependencyLocator<ContactRepository>();
  final _permissionRepository = dependencyLocator<PermissionRepository>();

  Future<Contact?> call({required String number}) async => _permissionRepository
      .getPermissionStatus(
        Permission.contacts,
      )
      .then(
        (status) async => status == PermissionStatus.granted
            ? _contactsRepository.getContactByPhoneNumber(number)
            : null,
      );
}

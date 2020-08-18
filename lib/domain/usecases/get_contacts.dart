import 'dart:async';

import '../entities/permission.dart';
import '../entities/permission_status.dart';
import '../entities/no_permission.dart';

import '../entities/contact.dart';

import '../repositories/contact.dart';
import '../repositories/permission.dart';
import '../use_case.dart';

class GetContactsUseCase extends FutureUseCase<List<Contact>> {
  final ContactRepository _contactsRepository;
  final PermissionRepository _permissionRepository;

  GetContactsUseCase(this._contactsRepository, this._permissionRepository);

  @override
  Future<List<Contact>> call() async {
    final status = await _permissionRepository.getPermissionStatus(
      Permission.contacts,
    );

    if (status != PermissionStatus.granted) {
      throw NoPermission();
    } else {
      return await _contactsRepository.getContacts();
    }
  }
}

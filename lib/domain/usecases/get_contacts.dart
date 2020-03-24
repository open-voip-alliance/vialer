import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../entities/permission.dart';
import '../entities/permission_status.dart';
import '../entities/no_permission.dart';

import '../entities/contact.dart';

import '../repositories/contact.dart';
import '../repositories/permission.dart';

class GetContactsUseCase extends UseCase<List<Contact>, void> {
  final ContactRepository _contactsRepository;
  final PermissionRepository _permissionRepository;

  GetContactsUseCase(this._contactsRepository, this._permissionRepository);

  @override
  Future<Stream<List<Contact>>> buildUseCaseStream(_) async {
    final controller = StreamController<List<Contact>>();

    final status = await _permissionRepository.getPermissionStatus(
      Permission.contacts,
    );

    if (status != PermissionStatus.granted) {
      controller.addError(NoPermission());
    } else {
      controller.add(await _contactsRepository.getContacts());
    }



    unawaited(controller.close());

    return controller.stream;
  }
}

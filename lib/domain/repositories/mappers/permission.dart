import 'package:permission_handler/permission_handler.dart';

import '../../entities/permission.dart' as domain;

Permission mapDomainPermissionToPermission(
  domain.Permission permission,
) {
  switch (permission) {
    case domain.Permission.phone:
      return Permission.phone;

    case domain.Permission.contacts:
      return Permission.contacts;

    default:
      throw UnsupportedError(
        'PermissionGroup has no equivalent domain entity Permission',
      );
  }
}

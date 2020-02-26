import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/onboarding/permission.dart' as domain;

PermissionGroup mapDomainPermissionToPermissionGroup(
  domain.Permission permission,
) {
  switch (permission) {
    case domain.Permission.phone:
      return PermissionGroup.phone;

    case domain.Permission.contacts:
      return PermissionGroup.contacts;

    default:
      throw UnsupportedError(
        'PermissionGroup has no equivalent domain entity Permission',
      );
  }
}

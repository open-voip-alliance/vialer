import 'package:permission_handler/permission_handler.dart';

import '../../entities/permission.dart' as domain;

extension PermissionMapper on domain.Permission {
  Permission toThirdPartyEntity() {
    switch (this) {
      case domain.Permission.phone:
        return Permission.phone;

      case domain.Permission.contacts:
        return Permission.contacts;

      default:
        throw UnsupportedError(
          'Domain Permission has no equivalent package Permission: $this',
        );
    }
  }
}

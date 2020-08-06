import '../entities/permission.dart';
import '../entities/permission_status.dart';

abstract class PermissionRepository {
  /// Returns whether the permission is `granted`, `denied`,
  /// `permanentlyDenied` or `unavailable`.
  Future<PermissionStatus> getPermissionStatus(Permission permission);

  /// Enable the permission, perhaps asking the user whether they want
  /// to grant it. Returns the resulting PermissionStatus.
  Future<PermissionStatus> enablePermission(Permission permission);
}

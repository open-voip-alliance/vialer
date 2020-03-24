import '../entities/permission.dart';
import '../entities/permission_status.dart';

abstract class PermissionRepository {
  /// Returns whether the permission is `granted`, `denied` or `unavailable`.
  Future<PermissionStatus> getPermissionStatus(Permission permission);

  /// Enable the permission, perhaps asking the user whether they want
  /// to grant it. Returns `true` if successful and `false` otherwise.
  Future<bool> enablePermission(Permission permission);
}

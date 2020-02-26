import '../entities/onboarding/permission.dart';
import '../entities/onboarding/permission_status.dart';

abstract class PermissionRepository {
  /// Returns whether the permission is `granted`, `denied` or `notApplicable`.
  Future<PermissionStatus> getPermissionStatus(Permission permission);

  /// Enable the permission, perhaps asking the user whether they want
  /// to grant it. Returns `true` if successful and `false` otherwise.
  Future<bool> enablePermission(Permission permission);
}

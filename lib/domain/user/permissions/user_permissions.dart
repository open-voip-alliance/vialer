import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_permissions.g.dart';

part 'user_permissions.freezed.dart';

@freezed
class UserPermissions with _$UserPermissions {
  const factory UserPermissions({
    @Default(false) bool canSeeClientCalls,
    @Default(false) bool canChangeMobileNumberFallback,
    @Default(false) bool canViewMobileNumberFallbackStatus,
    @Default(false) bool canChangeTemporaryRedirect,
    @Default(false) bool canViewVoicemailAccounts,
    @Default(false) bool canChangeOutgoingNumber,
    @Default(false) bool canViewColleagues,
    @Default(false) bool canViewVoipAccounts,
    @Default(false) bool canViewDialPlans,
    @Default(false) bool canViewStats,
    @Default(false) bool canChangeOpeningHours,
  }) = _UserPermissions;

  const UserPermissions._();

  factory UserPermissions.fromJson(Map<String, dynamic> json) =>
      _$UserPermissionsFromJson(json);

  static Map<String, dynamic>? serializeToJson(UserPermissions? permissions) =>
      permissions?.toJson();
}

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_permissions.g.dart';

@JsonSerializable()
class UserPermissions extends Equatable {
  @JsonKey(defaultValue: false)
  final bool canSeeClientCalls;

  @JsonKey(defaultValue: false)
  final bool canChangeMobileNumberFallback;

  @JsonKey(defaultValue: false)
  final bool canViewMobileNumberFallbackStatus;

  @JsonKey(defaultValue: false)
  final bool canUseTemporaryRedirect;

  const UserPermissions({
    required this.canSeeClientCalls,
    required this.canChangeMobileNumberFallback,
    required this.canViewMobileNumberFallbackStatus,
    required this.canUseTemporaryRedirect,
  });

  const UserPermissions.defaults()
      : this(
          canSeeClientCalls: false,
          canChangeMobileNumberFallback: false,
          canViewMobileNumberFallbackStatus: false,
          canUseTemporaryRedirect: false,
        );

  static UserPermissions fromJson(Map<String, dynamic> json) =>
      _$UserPermissionsFromJson(json);

  static Map<String, dynamic> toJson(UserPermissions value) =>
      _$UserPermissionsToJson(value);

  @override
  List<Object?> get props => [
        canSeeClientCalls,
        canChangeMobileNumberFallback,
        canViewMobileNumberFallbackStatus,
        canUseTemporaryRedirect,
      ];
}

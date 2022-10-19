import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_permissions.g.dart';

@JsonSerializable()
class UserPermissions extends Equatable {
  @JsonKey(defaultValue: false)
  final bool canSeeClientCalls;

  @JsonKey(defaultValue: false)
  final bool canUseMobileNumberFallback;

  const UserPermissions({
    required this.canSeeClientCalls,
    required this.canUseMobileNumberFallback,
  });

  const UserPermissions.defaults()
      : this(
          canSeeClientCalls: false,
          canUseMobileNumberFallback: false,
        );

  static UserPermissions fromJson(Map<String, dynamic> json) =>
      _$UserPermissionsFromJson(json);

  static Map<String, dynamic> toJson(UserPermissions value) =>
      _$UserPermissionsToJson(value);

  @override
  List<Object?> get props => [
        canSeeClientCalls,
        canUseMobileNumberFallback,
      ];
}

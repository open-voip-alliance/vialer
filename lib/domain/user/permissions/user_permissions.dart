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
  final bool canChangeTemporaryRedirect;

  @JsonKey(defaultValue: false)
  final bool canViewVoicemailAccounts;

  @JsonKey(defaultValue: false)
  final bool canChangeOutgoingNumber;

  @JsonKey(defaultValue: false)
  final bool canViewColleagues;

  @JsonKey(defaultValue: false)
  final bool canViewVoipAccounts;

  const UserPermissions({
    required this.canSeeClientCalls,
    required this.canChangeMobileNumberFallback,
    required this.canViewMobileNumberFallbackStatus,
    required this.canChangeTemporaryRedirect,
    required this.canViewVoicemailAccounts,
    required this.canChangeOutgoingNumber,
    required this.canViewColleagues,
    required this.canViewVoipAccounts,
  });

  const UserPermissions.defaults()
      : this(
          canSeeClientCalls: false,
          canChangeMobileNumberFallback: false,
          canViewMobileNumberFallbackStatus: false,
          canChangeTemporaryRedirect: false,
          canViewVoicemailAccounts: false,
          canChangeOutgoingNumber: false,
          canViewColleagues: false,
          canViewVoipAccounts: false,
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
        canChangeTemporaryRedirect,
        canViewVoicemailAccounts,
        canChangeOutgoingNumber,
        canViewColleagues,
        canViewVoipAccounts,
      ];
}

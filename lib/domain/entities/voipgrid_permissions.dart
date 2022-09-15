import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'voipgrid_permissions.g.dart';

@JsonSerializable()
class VoipgridPermissions extends Equatable {
  @JsonKey(defaultValue: false)
  final bool hasClientCallsPermission;

  @JsonKey(defaultValue: false)
  final bool hasMobileNumberFallbackPermission;

  const VoipgridPermissions({
    required this.hasClientCallsPermission,
    required this.hasMobileNumberFallbackPermission,
  });

  factory VoipgridPermissions.fromJson(Map<String, dynamic> json) =>
      _$VoipgridPermissionsFromJson(json);

  Map<String, dynamic> toJson() => _$VoipgridPermissionsToJson(this);

  @override
  List<Object?> get props => [
        hasClientCallsPermission,
        hasMobileNumberFallbackPermission,
      ];
}

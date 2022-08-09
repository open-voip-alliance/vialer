import 'package:json_annotation/json_annotation.dart';

part 'voipgrid_permissions.g.dart';

@JsonSerializable()
class VoipgridPermissions {
  final bool hasClientCallsPermission;

  const VoipgridPermissions({
    required this.hasClientCallsPermission,
  });

  factory VoipgridPermissions.fromJson(Map<String, dynamic> json) =>
      _$VoipgridPermissionsFromJson(json);

  Map<String, dynamic> toJson() => _$VoipgridPermissionsToJson(this);
}

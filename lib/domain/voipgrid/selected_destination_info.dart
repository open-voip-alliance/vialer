import 'package:json_annotation/json_annotation.dart';

part 'selected_destination_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SelectedDestinationInfo {
  final int id;

  @JsonKey(name: 'fixeddestination')
  final int? fixedDestinationId;

  @JsonKey(name: 'phoneaccount')
  final int? phoneAccountId;

  const SelectedDestinationInfo({
    required this.id,
    this.fixedDestinationId,
    this.phoneAccountId,
  });

  factory SelectedDestinationInfo.fromJson(Map<String, dynamic> json) =>
      _$SelectedDestinationInfoFromJson(json);
}

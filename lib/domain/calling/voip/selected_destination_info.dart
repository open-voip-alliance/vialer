import 'package:freezed_annotation/freezed_annotation.dart';

part 'selected_destination_info.freezed.dart';
part 'selected_destination_info.g.dart';

@freezed
class SelectedDestinationInfo with _$SelectedDestinationInfo {
  const factory SelectedDestinationInfo({
    required int id,
    @JsonKey(name: 'fixeddestination') int? fixedDestinationId,
    @JsonKey(name: 'phoneaccount') int? phoneAccountId,
  }) = _SelectedDestinationInfo;

  factory SelectedDestinationInfo.fromJson(Map<String, dynamic> json) =>
      _$SelectedDestinationInfoFromJson(json);
}

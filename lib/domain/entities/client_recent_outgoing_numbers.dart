import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_recent_outgoing_numbers.freezed.dart';
part 'client_recent_outgoing_numbers.g.dart';

@freezed
class ClientRecentOutgoingNumbers with _$ClientRecentOutgoingNumbers {
  factory ClientRecentOutgoingNumbers({
    required List<String> numbers,
  }) = _ClientRecentOutgoingNumbers;

  factory ClientRecentOutgoingNumbers.fromJson(Map<String, Object?> json) =>
      _$ClientRecentOutgoingNumbersFromJson(json);
}

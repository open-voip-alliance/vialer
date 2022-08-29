import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'client_available_outgoing_numbers.g.dart';

/// This represents the business numbers that are available to the client
/// the logged-in user belongs to.
@JsonSerializable(fieldRename: FieldRename.snake)
class ClientAvailableOutgoingNumbers extends Equatable {
  final List<String> numbers;

  const ClientAvailableOutgoingNumbers({
    required this.numbers,
  });

  @override
  List<Object?> get props => numbers;

  factory ClientAvailableOutgoingNumbers.fromJson(Map<String, dynamic> json) =>
      _$ClientAvailableOutgoingNumbersFromJson(json);

  Map<String, dynamic> toJson() => _$ClientAvailableOutgoingNumbersToJson(this);
}

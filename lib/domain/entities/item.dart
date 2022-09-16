import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item extends Equatable {
  final String label;
  final String value;

  const Item(this.label, this.value);

  @override
  String toString() => '$label: $value';

  @override
  List<Object?> get props => [
        value,
      ];

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

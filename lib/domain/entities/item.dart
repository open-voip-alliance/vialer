import 'package:equatable/equatable.dart';

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
}

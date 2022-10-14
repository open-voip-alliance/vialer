import 'package:equatable/equatable.dart';

abstract class Destination extends Equatable {
  int? get id;

  String? get description;

  const Destination();

  @override
  List<Object?> get props => [id, description];
}

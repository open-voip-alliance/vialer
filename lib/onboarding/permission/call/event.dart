import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class CallPermissionEvent extends Equatable {}

class Request extends CallPermissionEvent {
  @override
  List<Object> get props => [];
}

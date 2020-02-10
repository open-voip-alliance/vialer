import 'package:equatable/equatable.dart';

abstract class CallPermissionState extends Equatable {
  @override
  List<Object> get props => [];
}

class NotRequested extends CallPermissionState {}

class Granted extends CallPermissionState {}

class Denied extends CallPermissionState {}

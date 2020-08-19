import 'package:equatable/equatable.dart';

class PermissionState extends Equatable {
  @override
  List<Object> get props => [];
}

class PermissionNotRequested extends PermissionState {}

class PermissionGranted extends PermissionState {}

class PermissionDenied extends PermissionState {}

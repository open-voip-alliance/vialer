import 'package:equatable/equatable.dart';

abstract class AppUpdatedState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NewUpdateWasInstalled extends AppUpdatedState {
  final String version;

  NewUpdateWasInstalled(this.version);
}

class AppWasNotUpdated extends AppUpdatedState {}

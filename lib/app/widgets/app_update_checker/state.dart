import 'package:equatable/equatable.dart';

abstract class AppUpdateState extends Equatable {
  const AppUpdateState();

  @override
  List<Object?> get props => [];
}

class NewUpdateWasInstalled extends AppUpdateState {
  final String version;

  const NewUpdateWasInstalled(this.version);
}

class UpdateReadyToInstall extends AppUpdateState {
  const UpdateReadyToInstall();
}

class AppWasNotUpdated extends AppUpdateState {
  const AppWasNotUpdated();
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
sealed class AppUpdateState with _$AppUpdateState {
  const factory AppUpdateState.newUpdateWasInstalled() = NewUpdateWasInstalled;
  const factory AppUpdateState.updateReadyToInstall() = UpdateReadyToInstall;
  const factory AppUpdateState.appWasNotUpdated() = AppWasNotUpdated;
}

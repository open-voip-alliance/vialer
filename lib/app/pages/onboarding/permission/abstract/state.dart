import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
sealed class PermissionState with _$PermissionState {
  const factory PermissionState.notRequested() = PermissionNotRequested;
  const factory PermissionState.granted() = PermissionGranted;
  const factory PermissionState.denied() = PermissionDenied;
}

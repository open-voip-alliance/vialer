import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
sealed class MobileNumberState with _$MobileNumberState {
  const factory MobileNumberState(String mobileNumber) = _MobileNumberState;
  const factory MobileNumberState.accepted(String mobileNumber) =
      MobileNumberAccepted;
  const factory MobileNumberState.notAccepted(String mobileNumber) =
      MobileNumberNotAccepted;
}

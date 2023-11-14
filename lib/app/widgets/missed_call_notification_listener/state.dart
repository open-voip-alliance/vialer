import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
sealed class MissedCallNotificationPressedListenerState
    with _$MissedCallNotificationPressedListenerState {
  const factory MissedCallNotificationPressedListenerState.notPressed() =
      MissedCallNotificationNotPressed;
  const factory MissedCallNotificationPressedListenerState.pressed() =
      MissedCallNotificationPressed;
}

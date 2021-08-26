import 'package:equatable/equatable.dart';

abstract class MissedCallNotificationPressedListenerState {
  const MissedCallNotificationPressedListenerState();
}

class MissedCallNotificationNotPressed extends Equatable
    implements MissedCallNotificationPressedListenerState {
  const MissedCallNotificationNotPressed();

  @override
  List<Object?> get props => [];
}

/// This state does _not_ extend [Equatable], since it should not be equal
/// to other [MissedCallNotificationPressed] states in any scenario.
class MissedCallNotificationPressed
    extends MissedCallNotificationPressedListenerState {}

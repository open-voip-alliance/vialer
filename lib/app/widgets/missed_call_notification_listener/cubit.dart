import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/calling/get_missed_call_notification_pressed_stream.dart';
import 'state.dart';

export 'state.dart';

class MissedCallNotificationPressedListenerCubit
    extends Cubit<MissedCallNotificationPressedListenerState> {
  MissedCallNotificationPressedListenerCubit()
      : super(const MissedCallNotificationNotPressed()) {
    _subscription = _getMissedCallNotificationPressedStream().listen((_) {
      emit(MissedCallNotificationPressed());
    });
  }

  final _getMissedCallNotificationPressedStream =
      GetMissedCallNotificationPressedStream();

  late StreamSubscription<bool> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}

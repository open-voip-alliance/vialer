import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_missed_call_notification_pressed_stream.dart';
import 'state.dart';

export 'state.dart';

class MissedCallNotificationPressedListenerCubit
    extends Cubit<MissedCallNotificationPressedListenerState> {
  final _getMissedCallNotificationPressedStream =
      GetMissedCallNotificationPressedStream();

  late StreamSubscription _subscription;

  MissedCallNotificationPressedListenerCubit()
      : super(const MissedCallNotificationNotPressed()) {
    _subscription = _getMissedCallNotificationPressedStream().listen((_) {
      emit(MissedCallNotificationPressed());
    });
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}

import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:bloc/bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'event.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

class DialerBloc extends Bloc<DialerEvent, DialerState> {
  @override
  DialerState get initialState => Dialing();

  @override
  Stream<DialerState> mapEventToState(DialerEvent event) async* {
    if (event is Call) {
      if (Platform.isAndroid) {
        await PermissionHandler().requestPermissions([PermissionGroup.phone]);

        final intent = AndroidIntent(
          action: 'android.intent.action.CALL',
          data: 'tel:${event.phoneNumber}',
        );

        await intent.launch();
      }
    }
  }
}

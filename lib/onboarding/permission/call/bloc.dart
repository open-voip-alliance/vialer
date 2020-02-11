export 'event.dart';
export 'state.dart';

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'event.dart';
import 'state.dart';

class CallPermissionBloc
    extends Bloc<CallPermissionEvent, CallPermissionState> {
  static Future<bool> shouldAddStep() async {
    if (Platform.isAndroid) {
      final callPermissionStatus = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.phone);

      return callPermissionStatus != PermissionStatus.granted;
    } else {
      return false;
    }
  }

  @override
  CallPermissionState get initialState => NotRequested();

  @override
  Stream<CallPermissionState> mapEventToState(
      CallPermissionEvent event) async* {
    if (event is Request) {
      final permissions = await PermissionHandler().requestPermissions(
        [PermissionGroup.phone],
      );

      final status = permissions[PermissionGroup.phone];

      if (status == PermissionStatus.granted) {
        yield Granted();
      } else {
        yield Denied();
      }
    }
  }
}

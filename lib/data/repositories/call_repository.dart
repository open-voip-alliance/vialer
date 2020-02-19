import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/repositories/call_repository.dart';

class DataCallRepository extends CallRepository {
  @override
  Future<void> call(String destination) async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.intent.action.CALL',
        data: 'tel:$destination',
      );

      await intent.launch();
    } else {
      await launch('tel:$destination');
    }
  }
}

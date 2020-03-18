import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import 'confirm/page.dart';

mixin Caller on Controller {
  
  void executeCall(String destination);

  void call(String destination) {
    if (Platform.isIOS) {
      logger.info('Start calling: $destination, going to call through page');
      Navigator.push(
        getContext(),
        ConfirmPageRoute(destination: destination),
      );
    } else {
      logger.info('Calling $destination');
      executeCall(destination);
    }
  }
}

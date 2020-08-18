import 'dart:async';

import 'package:chopper/chopper.dart';

part 'feedback.chopper.dart';

@ChopperApi()
abstract class FeedbackService extends ChopperService {
  static FeedbackService create() {
    return _$FeedbackService(
      ChopperClient(
        baseUrl: 'https://feedback.spindle.dev/',
        converter: JsonConverter(),
      ),
    );
  }

  @Post(path: 'v2/feedback/app')
  Future<Response> feedback(@Body() Map<String, dynamic> body);
}

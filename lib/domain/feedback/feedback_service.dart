import 'dart:async';

import 'package:chopper/chopper.dart';

part 'feedback_service.chopper.dart';

@ChopperApi()
abstract class FeedbackService extends ChopperService {
  static FeedbackService create() {
    return _$FeedbackService(
      ChopperClient(
        baseUrl: 'https://feedback.spindle.dev/',
        converter: const JsonConverter(),
      ),
    );
  }

  @Post(path: 'v2/feedback/app')
  Future<Response<Map<String, dynamic>>> feedback(
    @Body() Map<String, dynamic> body,
  );
}

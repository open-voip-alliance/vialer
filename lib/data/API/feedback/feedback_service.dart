import 'dart:async';

import 'package:chopper/chopper.dart';

part 'feedback_service.chopper.dart';

@ChopperApi()
abstract class FeedbackService extends ChopperService {
  static FeedbackService create() {
    return _$FeedbackService(
      ChopperClient(
        baseUrl: Uri.parse('https://feedback.spindle.dev/'),
        converter: const JsonConverter(),
      ),
    );
  }

  @Post(path: 'v2/feedback/app')
  Future<Response<String>> feedback(
    @Body() Map<String, dynamic> body,
  );
}

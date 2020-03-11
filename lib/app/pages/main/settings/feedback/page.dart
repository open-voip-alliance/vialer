import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../resources/theme.dart';
import '../../../../resources/localizations.dart';

import '../../../../widgets/transparent_status_bar.dart';
import '../../widgets/colored_button.dart';

import '../../../../../domain/repositories/feedback.dart';
import '../../../../../domain/repositories/auth.dart';

import 'controller.dart';

class FeedbackPage extends View {
  final FeedbackRepository _feedbackRepository;
  final AuthRepository _authRepository;

  FeedbackPage(this._feedbackRepository, this._authRepository);

  @override
  State<StatefulWidget> createState() =>
      _FeedbackPageState(_feedbackRepository, _authRepository);
}

class _FeedbackPageState extends ViewState<FeedbackPage, DialerController> {
  _FeedbackPageState(
    FeedbackRepository feedbackRepository,
    AuthRepository authRepository,
  ) : super(DialerController(feedbackRepository, authRepository));

  @override
  Widget buildPage() {
    var sendFeedbackButtonText =
        context.msg.main.settings.feedback.buttons.send;
    if (context.isAndroid) {
      sendFeedbackButtonText = sendFeedbackButtonText.toUpperCase();
    }

    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text(
          'Feedback',
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        centerTitle: true,
      ),
      body: TransparentStatusBar(
        brightness: Brightness.dark,
        child: Column(
          children: <Widget>[
            TextField(
              controller: controller.titleController,
              decoration: InputDecoration(
                hintText: context.msg.main.settings.feedback.placeholders.title,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                hintStyle: TextStyle(
                  color: VialerColors.grey4,
                ),
              ),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: TextField(
                controller: controller.textController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText:
                      context.msg.main.settings.feedback.placeholders.text,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  hintStyle: TextStyle(
                    color: VialerColors.grey4,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 40,
              ).copyWith(
                bottom: 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ColoredButton.filled(
                  onPressed: controller.sendFeedback,
                  child: Text(sendFeedbackButtonText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

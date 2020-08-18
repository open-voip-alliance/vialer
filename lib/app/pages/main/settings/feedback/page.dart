import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../resources/theme.dart';
import '../../../../resources/localizations.dart';

import '../../../../widgets/transparent_status_bar.dart';
import '../../../../widgets/stylized_button.dart';

import '../../../../util/conditional_capitalization.dart';

import 'controller.dart';

class FeedbackPage extends View {
  @override
  State<StatefulWidget> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ViewState<FeedbackPage, DialerController> {
  _FeedbackPageState() : super(DialerController());

  @override
  Widget buildPage() {
    final sendFeedbackButtonText = context
        .msg.main.settings.feedback.buttons.send
        .toUpperCaseIfAndroid(context);

    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text(context.msg.main.settings.feedback.title),
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
                  color: context.brandTheme.grey4,
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
                    color: context.brandTheme.grey4,
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
                child: StylizedButton.raised(
                  colored: true,
                  onPressed: controller.sendFeedback,
                  child: Text(
                    sendFeedbackButtonText.toUpperCaseIfAndroid(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

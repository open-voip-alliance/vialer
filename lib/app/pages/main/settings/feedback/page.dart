import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../../widgets/stylized_button.dart';
import '../../../../widgets/transparent_status_bar.dart';
import '../../widgets/header.dart';
import 'cubit.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _textController = TextEditingController();

  void _onStateChanged(BuildContext context, FeedbackState state) {
    if (state is FeedbackSent) {
      Navigator.pop(context, true /* Whether feedback was sent */);
    }
  }

  void _sendFeedback(
    BuildContext context, {
    required String text,
    required bool withLogs,
  }) {
    final feedback = context.read<FeedbackCubit>();

    if (withLogs) {
      feedback.enableThenSendLogsToRemote();
    }

    Navigator.pop(context);

    feedback.sendFeedback(
      title: 'Feedback',
      text: text,
    );
  }

  void _onSendFeedbackPressed(BuildContext buildContext, String text) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          context.msg.main.settings.feedback.logs(
            context.brand.appName,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              primary: context.brand.theme.colors.primary,
            ),
            onPressed: () => _sendFeedback(
              buildContext,
              text: text,
              withLogs: false,
            ),
            child: Text(
              context.msg.generic.button.noThanks.toUpperCaseIfAndroid(context),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              primary: context.brand.theme.colors.primary,
            ),
            onPressed: () => _sendFeedback(
              buildContext,
              text: text,
              withLogs: true,
            ),
            child: Text(
              context.msg.generic.button.yes.toUpperCaseIfAndroid(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sendFeedbackButtonText = context
        .msg.main.settings.feedback.buttons.send
        .toUpperCaseIfAndroid(context);

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return BlocProvider<FeedbackCubit>(
      create: (_) => FeedbackCubit(),
      child: BlocListener<FeedbackCubit, FeedbackState>(
        listener: _onStateChanged,
        child: BlocBuilder<FeedbackCubit, FeedbackState>(
          builder: (context, state) {
            return Scaffold(
              body: TransparentStatusBar(
                brightness: Brightness.light,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ).copyWith(
                    top: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Header(
                              context.msg.main.settings.feedback.title,
                            ),
                          ),
                        ],
                      ),
                      _FeedbackFormHeader(
                        visible: !isKeyboardOpen,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 0,
                          ),
                          child: TextField(
                            expands: true,
                            controller: _textController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: context
                                  .msg.main.settings.feedback.placeholders.text,
                              hintMaxLines: 4,
                              border: InputBorder.none,
                              filled: true,
                              fillColor: context.brand.theme.colors.primaryLight
                                  .withOpacity(0.6),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              hintStyle: TextStyle(
                                color: context.brand.theme.colors.grey4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ).copyWith(
                          bottom: 16,
                          top: 60,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: StylizedButton.raised(
                            colored: true,
                            onPressed: state is FeedbackNotSent
                                ? () => _onSendFeedbackPressed(
                                      context,
                                      _textController.text,
                                    )
                                : null,
                            child: Text(
                              sendFeedbackButtonText
                                  .toUpperCaseIfAndroid(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeedbackFormHeader extends StatelessWidget {
  final bool visible;

  const _FeedbackFormHeader({
    Key? key,
    required this.visible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 8,
        ),
        color: context.brand.theme.colors.primaryLight.withOpacity(0.6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                VialerSans.feedback,
                size: 16,
                color: context.brand.theme.colors.primaryDark,
              ),
            ),
            Flexible(
              child: Text(
                context.msg.main.settings.feedback.callout(
                  context.brand.appName,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

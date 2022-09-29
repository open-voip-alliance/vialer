import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../../widgets/stylized_button.dart';
import '../../../../widgets/transparent_status_bar.dart';
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
              appBar: AppBar(
                title: Text(context.msg.main.settings.feedback.title),
                centerTitle: true,
              ),
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
                      _FeedbackFormHeader(
                        visible: !isKeyboardOpen,
                      ),
                      Expanded(
                        child: _FeedbackInput(controller: _textController),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
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

class _FeedbackInput extends StatelessWidget {
  final TextEditingController controller;

  const _FeedbackInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextField(
        expands: true,
        controller: controller,
        maxLines: null,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: context.msg.main.settings.feedback.placeholders.text,
          hintMaxLines: 4,
          border: OutlineInputBorder(
            borderRadius: borderRadius,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: context.brand.theme.colors.grey3,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: context.brand.theme.colors.primaryLight,
              width: 2,
            ),
          ),
          focusColor: context.brand.theme.colors.primaryLight,
          contentPadding: const EdgeInsets.all(16),
          hintStyle: TextStyle(
            color: context.brand.theme.colors.grey4,
          ),
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
    // TODO: Make it smoothly animated.
    return Visibility(
      visible: visible,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: context.brand.theme.colors.grey5.withOpacity(0.15)),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.comments,
                  size: 24,
                  color: context.brand.theme.colors.grey5,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.msg.main.settings.feedback.placeholders.text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.msg.main.settings.feedback
                  .description(context.brand.appName),
            ),
            const SizedBox(height: 8),
            Text(
              context.msg.main.settings.feedback.urgent,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

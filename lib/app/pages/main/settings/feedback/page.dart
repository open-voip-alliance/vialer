import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/theme.dart';
import '../../../../resources/localizations.dart';

import '../../../../widgets/transparent_status_bar.dart';
import '../../../../widgets/stylized_button.dart';

import '../../../../util/conditional_capitalization.dart';

import 'cubit.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();

  void _onStateChanged(BuildContext context, FeedbackState state) {
    if (state is FeedbackSent) {
      Navigator.pop(context, true /* Whether feedback was sent */);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sendFeedbackButtonText = context
        .msg.main.settings.feedback.buttons.send
        .toUpperCaseIfAndroid(context);

    return BlocProvider<FeedbackCubit>(
      create: (_) => FeedbackCubit(),
      child: BlocListener<FeedbackCubit, FeedbackState>(
        listener: _onStateChanged,
        // Using a regular Builder, because we don't need to rebuild
        // on cubit's state change, but still need right context to get the
        // cubit
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(context.msg.main.settings.feedback.title),
                centerTitle: true,
              ),
              body: TransparentStatusBar(
                brightness: Brightness.light,
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: context
                            .msg.main.settings.feedback.placeholders.title,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
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
                        controller: _textController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: context
                              .msg.main.settings.feedback.placeholders.text,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                      ).copyWith(
                        bottom: 16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: StylizedButton.raised(
                          colored: true,
                          onPressed: () =>
                              context.read<FeedbackCubit>().sendFeedback(
                                    title: _titleController.text,
                                    text: _textController.text,
                                  ),
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
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                                ? () =>
                                    context.read<FeedbackCubit>().sendFeedback(
                                          title: 'Feedback',
                                          text: _textController.text,
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

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../domain/feedback/call_problem.dart';
import '../../../../resources/theme.dart';
import 'call_rating.dart';
import 'select_audio_problems.dart';
import 'select_call_problem.dart';
import 'written_feedback.dart';

class CallFeedback extends StatefulWidget {
  /// All the feedback items have been collected and we can process the given
  /// feedback. This does not mean the user is done and so this should not
  /// be dismissed yet.
  final Function(CallFeedbackResult result) onFeedbackReady;

  /// The user has finished the whole feedback process, so the widget can be
  /// dismissed.
  final VoidCallback onUserFinishedFeedbackProcess;

  /// The minimum rating that is considered a "positive" rating and will not
  /// prompt for further feedback. This is inclusive, so if set to 4 then 4 and
  /// 5 are counted as positive ratings.
  final int positiveRatingThreshold;

  const CallFeedback({
    required this.onFeedbackReady,
    required this.onUserFinishedFeedbackProcess,
    this.positiveRatingThreshold = 4,
  });

  @override
  State<StatefulWidget> createState() => _CallFeedbackState();
}

class _CallFeedbackState extends State<CallFeedback> {
  /// This is the end result of the user feedback and should be submitted
  /// when it has been completed via the [onFeedbackReady]
  /// callback.
  var _result = const CallFeedbackResult.fresh();

  /// The current stage that should be rendered, this is determined by the
  /// data within the [_result] object.
  CallFeedbackStage get _stage {
    final rating = _result.rating;
    final problem = _result.problem;
    final audioProblems = _result.audioProblems;

    if (rating == null || rating >= widget.positiveRatingThreshold) {
      return CallFeedbackStage.rateCall;
    }

    if (problem == null) {
      return CallFeedbackStage.selectCallProblem;
    }

    if (problem == CallProblem.audioProblem && audioProblems == null) {
      return CallFeedbackStage.selectAudioProblem;
    }

    return CallFeedbackStage.provideWrittenFeedback;
  }

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 10), () {
      // The call feedback should only be automatically dismissed if the user
      // doesn't want to engage with it, therefore they are still on the first
      // stage.
      if (_stage == CallFeedbackStage.rateCall) {
        widget.onUserFinishedFeedbackProcess();
      }
    });
  }

  void _onCallRated(double rating) {
    final result = _result.copyWith(rating: rating);

    if (rating >= widget.positiveRatingThreshold) {
      widget.onFeedbackReady(result);
      widget.onUserFinishedFeedbackProcess();
      return;
    }

    setState(() {
      _result = result;
    });
  }

  void _onProblemSelected(CallProblem problem) {
    final result = _result.copyWith(problem: problem);

    if (problem != CallProblem.audioProblem) {
      widget.onFeedbackReady(result);
    }

    setState(() {
      _result = result;
    });
  }

  void _onAudioProblemsSelected(List<CallAudioProblem> audioProblems) {
    final result = _result.copyWith(audioProblems: audioProblems);

    widget.onFeedbackReady(result);

    setState(() {
      _result = result;
    });
  }

  Widget _buildForCurrentStage() {
    switch (_stage) {
      case CallFeedbackStage.rateCall:
        return CallRating(
          onComplete: _onCallRated,
        );
      case CallFeedbackStage.selectCallProblem:
        return SelectCallProblem(
          onComplete: _onProblemSelected,
        );
      case CallFeedbackStage.provideWrittenFeedback:
        return WrittenFeedback(
          onComplete: widget.onUserFinishedFeedbackProcess,
        );
      case CallFeedbackStage.selectAudioProblem:
        return SelectAudioProblems(
          onComplete: _onAudioProblemsSelected,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 10,
        sigmaY: 10,
      ),
      child: _buildForCurrentStage(),
    );
  }
}

class CallFeedbackAlertDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final TextAlign? titleAlign;

  const CallFeedbackAlertDialog({
    this.title,
    required this.content,
    this.actions,
    this.titleAlign,
  });

  @override
  Widget build(BuildContext context) {
    final actions = this.actions ?? [];

    return AlertDialog(
      title: title != null
          ? Text(
              title!,
              textAlign: titleAlign != null ? titleAlign : TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.brand.theme.colors.grey6,
                fontSize: 16,
              ),
            )
          : null,
      content: content,
      actionsAlignment: actions.length >= 2
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.end,
      actions: actions,
    );
  }
}

/// Describes the stage of the feedback process the user is currently in.
enum CallFeedbackStage {
  rateCall,
  selectCallProblem,
  provideWrittenFeedback,
  selectAudioProblem,
}

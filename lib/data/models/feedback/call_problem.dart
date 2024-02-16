import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_problem.freezed.dart';

enum CallProblem {
  oneWayAudio,
  noAudio,
  audioProblem,
  endedUnexpectedly,
  somethingElse,
}

enum CallAudioProblem {
  jitter,
  echo,
  crackling,
  robotic,
  tooQuiet,
  tooLoud,
}

extension CallProblemString on CallProblem {
  String toShortString() => toString().split('.').last;
}

extension AudioProblemsString on CallAudioProblem {
  String toShortString() => toString().split('.').last;
}

@freezed
class CallFeedbackResult with _$CallFeedbackResult {
  const factory CallFeedbackResult({
    required double? rating,
    required CallProblem? problem,
    required List<CallAudioProblem>? audioProblems,
  }) = _CallFeedbackResult;

  factory CallFeedbackResult.fresh() => const CallFeedbackResult(
        rating: null,
        problem: null,
        audioProblems: null,
      );
}

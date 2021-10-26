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

class CallFeedbackResult {
  final double? rating;
  final CallProblem? problem;
  final List<CallAudioProblem>? audioProblems;

  const CallFeedbackResult({
    required this.rating,
    required this.problem,
    required this.audioProblems,
  });

  const CallFeedbackResult.fresh()
      : rating = null,
        problem = null,
        audioProblems = null;

  CallFeedbackResult copyWith({
    double? rating,
    CallProblem? problem,
    List<CallAudioProblem>? audioProblems,
  }) =>
      CallFeedbackResult(
        rating: rating ?? this.rating,
        problem: problem ?? this.problem,
        audioProblems: audioProblems ?? this.audioProblems,
      );
}

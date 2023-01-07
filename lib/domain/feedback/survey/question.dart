import 'package:freezed_annotation/freezed_annotation.dart';

part 'question.freezed.dart';

@freezed
class Question with _$Question {
  @Assert('answers.length == 5')
  const factory Question({
    required int id,

    /// The question phrase.
    required String phrase,

    /// Answers, from 1 to 5.
    required List<String> answers,
  }) = _Question;
}

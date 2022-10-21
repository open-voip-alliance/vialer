import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final int id;

  /// The question phrase.
  final String phrase;

  /// Answers, from 1 to 5.
  final List<String> answers;

  const Question({
    required this.id,
    required this.phrase,
    required this.answers,
  }) : assert(answers.length == 5);

  @override
  List<Object?> get props => [id, phrase, answers];
}

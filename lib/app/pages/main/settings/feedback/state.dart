import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
sealed class FeedbackState with _$FeedbackState {
  const factory FeedbackState.feedbackSending() = FeedbackSending;
  const factory FeedbackState.feedbackNotSent() = FeedbackNotSent;
  const factory FeedbackState.feedbackSent() = FeedbackSent;
}
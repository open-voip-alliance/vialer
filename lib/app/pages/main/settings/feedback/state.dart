import 'package:equatable/equatable.dart';

abstract class FeedbackState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedbackSending extends FeedbackState {}

class FeedbackNotSent extends FeedbackState {}

class FeedbackSent extends FeedbackState {}

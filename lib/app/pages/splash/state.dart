import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckingIsAuthenticated extends SplashState {}

class IsAuthenticated extends SplashState {}

class IsNotAuthenticated extends SplashState {}

import 'package:equatable/equatable.dart';

abstract class SplashScreenState extends Equatable {

  @override
  List<Object> get props => [];
}

class SplashScreenShowing extends SplashScreenState {}

class SplashScreenShown extends SplashScreenState {}

import 'package:equatable/equatable.dart';

class MobileNumberState extends Equatable {
  final String? mobileNumber;

  MobileNumberState({this.mobileNumber});

  MobileNumberState copyWith({String? mobileNumber}) {
    return MobileNumberState(
      mobileNumber: mobileNumber ?? this.mobileNumber,
    );
  }

  @override
  List<Object?> get props => [mobileNumber];
}

class MobileNumberChanged extends MobileNumberState {
  MobileNumberChanged({String? mobileNumber})
      : super(mobileNumber: mobileNumber);
}

class MobileNumberNotChanged extends MobileNumberState {
  MobileNumberNotChanged({String? mobileNumber})
      : super(mobileNumber: mobileNumber);
}

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

class MobileNumberAccepted extends MobileNumberState {
  MobileNumberAccepted({String? mobileNumber})
      : super(mobileNumber: mobileNumber);
}

class MobileNumberNotAccepted extends MobileNumberState {
  MobileNumberNotAccepted({String? mobileNumber})
      : super(mobileNumber: mobileNumber);
}

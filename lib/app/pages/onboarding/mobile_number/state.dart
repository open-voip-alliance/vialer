import 'package:equatable/equatable.dart';

class MobileNumberState extends Equatable {
  final String mobileNumber;

  const MobileNumberState(this.mobileNumber);

  @override
  List<Object?> get props => [mobileNumber];
}

class MobileNumberAccepted extends MobileNumberState {
  const MobileNumberAccepted(super.mobileNumber);
}

class MobileNumberNotAccepted extends MobileNumberState {
  const MobileNumberNotAccepted(super.mobileNumber);
}

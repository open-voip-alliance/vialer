import 'package:equatable/equatable.dart';

class MobileNumberState extends Equatable {
  const MobileNumberState(this.mobileNumber);

  final String mobileNumber;

  @override
  List<Object?> get props => [mobileNumber];
}

class MobileNumberAccepted extends MobileNumberState {
  const MobileNumberAccepted(super.mobileNumber);
}

class MobileNumberNotAccepted extends MobileNumberState {
  const MobileNumberNotAccepted(super.mobileNumber);
}

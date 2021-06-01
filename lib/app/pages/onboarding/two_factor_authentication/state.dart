import 'package:equatable/equatable.dart';

abstract class TwoFactorState extends Equatable {
  const TwoFactorState();

  @override
  List<Object?> get props => [];
}

class CodeNotSubmitted extends TwoFactorState {
  const CodeNotSubmitted();
}

class AwaitingServerResponse extends TwoFactorState {
  const AwaitingServerResponse();
}

class CodeAccepted extends TwoFactorState {
  const CodeAccepted();
}

class PasswordChangeRequired extends TwoFactorState {
  const PasswordChangeRequired();
}

class CodeRejected extends TwoFactorState {
  const CodeRejected();
}

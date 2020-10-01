import 'package:equatable/equatable.dart';

class ConfirmState extends Equatable {
  final String outgoingCli;
  final bool showConfirmPage;

  ConfirmState({this.outgoingCli, this.showConfirmPage});

  ConfirmState copyWith({String outgoingCli, bool showConfirmPage}) {
    return ConfirmState(
      outgoingCli: outgoingCli ?? this.outgoingCli,
      showConfirmPage: showConfirmPage ?? this.showConfirmPage,
    );
  }

  @override
  List<Object> get props => [outgoingCli, showConfirmPage];
}

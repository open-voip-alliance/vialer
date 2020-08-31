import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

import '../../../../../domain/entities/call_through_exception.dart';

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

class ConfirmError extends ConfirmState {
  final CallThroughException exception;

  ConfirmError(this.exception, {@required ConfirmState base})
      : super(
          outgoingCli: base.outgoingCli,
          showConfirmPage: base.showConfirmPage,
        );

  @override
  List<Object> get props => [outgoingCli, showConfirmPage, exception];
}

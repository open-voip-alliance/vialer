import 'package:equatable/equatable.dart';

class ConfirmState extends Equatable {
  final String? outgoingCli;
  final String? regionNumber;
  final bool showConfirmPage;

  const ConfirmState({
    this.outgoingCli,
    this.regionNumber,
    required this.showConfirmPage,
  });

  ConfirmState copyWith({
    String? outgoingCli,
    String? regionNumber,
    bool? showConfirmPage,
  }) {
    return ConfirmState(
      outgoingCli: outgoingCli ?? this.outgoingCli,
      regionNumber: regionNumber ?? this.regionNumber,
      showConfirmPage: showConfirmPage ?? this.showConfirmPage,
    );
  }

  @override
  List<Object?> get props => [outgoingCli, regionNumber, showConfirmPage];
}

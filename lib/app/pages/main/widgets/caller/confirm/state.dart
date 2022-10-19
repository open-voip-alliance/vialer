import 'package:equatable/equatable.dart';

import '../../../../../../domain/user/settings/call_setting.dart';

class ConfirmState extends Equatable {
  final OutgoingNumber outgoingNumber;
  final String? regionNumber;
  final bool showConfirmPage;

  const ConfirmState({
    required this.outgoingNumber,
    this.regionNumber,
    required this.showConfirmPage,
  });

  ConfirmState copyWith({
    OutgoingNumber? outgoingNumber,
    String? regionNumber,
    bool? showConfirmPage,
  }) {
    return ConfirmState(
      outgoingNumber: outgoingNumber ?? this.outgoingNumber,
      regionNumber: regionNumber ?? this.regionNumber,
      showConfirmPage: showConfirmPage ?? this.showConfirmPage,
    );
  }

  @override
  List<Object?> get props => [outgoingNumber, regionNumber, showConfirmPage];
}

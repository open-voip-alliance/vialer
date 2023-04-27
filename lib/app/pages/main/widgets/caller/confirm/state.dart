import 'package:equatable/equatable.dart';

import '../../../../../../domain/user/settings/call_setting.dart';

class ConfirmState extends Equatable {
  const ConfirmState({
    required this.showConfirmPage,
    required this.outgoingNumber,
    this.regionNumber,
  });

  final OutgoingNumber outgoingNumber;
  final String? regionNumber;
  final bool showConfirmPage;

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

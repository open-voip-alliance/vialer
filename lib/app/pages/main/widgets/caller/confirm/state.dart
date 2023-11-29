import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../domain/calling/outgoing_number/outgoing_number.dart';

part 'state.freezed.dart';

@freezed
class ConfirmState with _$ConfirmState {
  const factory ConfirmState({
    required bool showConfirmPage,
    required OutgoingNumber outgoingNumber,
    String? regionNumber,
  }) = _ConfirmState;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
class DialerState with _$DialerState {
  const factory DialerState({String? lastCalledDestination}) = _DialerState;
}

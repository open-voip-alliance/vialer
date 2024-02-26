import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
sealed class ClipboardState with _$ClipboardState {
  const factory ClipboardState.initial() = Initial;
  const factory ClipboardState.loading() = Loading;
  const factory ClipboardState.success(String number) = Success;
  const factory ClipboardState.unavailable() = Unavailable;
}

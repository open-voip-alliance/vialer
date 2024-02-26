import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vialer/domain/usecases/clipboard/get_number_from_clipboard.dart';
import 'package:vialer/presentation/shared/controllers/dial_pad/state.dart';

part 'riverpod.g.dart';

@Riverpod(keepAlive: true)
class Clipboard extends _$Clipboard {
  late final _getClipboardUseCase = GetNumberFromClipboardUseCase();

  ClipboardState build() => ClipboardState.initial();

  Future<void> getNumberFromClipboard() async {
    if (Platform.isIOS) {
      state = ClipboardState.unavailable();
      return;
    }

    state = ClipboardState.loading();
    final number = await _getClipboardUseCase();
    state = number != null
        ? ClipboardState.success(number)
        : ClipboardState.unavailable();
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vialer/domain/usecases/clipboard/get_number_from_clipboard.dart';
import 'package:vialer/domain/usecases/clipboard/has_number_from_clipboard.dart';
import 'package:vialer/presentation/shared/controllers/dial_pad/state.dart';

part 'riverpod.g.dart';

@Riverpod(keepAlive: true)
class Clipboard extends _$Clipboard {
  late final _getClipboardUseCase = GetNumberFromClipboardUseCase();
  late final _hasClipboardUseCase = HasNumberFromClipboardUseCase();

  ClipboardState build() => ClipboardState.initial();

  Future<void> getNumberFromClipboard() async {
    state = ClipboardState.loading();
    final number = await _getClipboardUseCase();
    state = number != null
        ? ClipboardState.success(number)
        : ClipboardState.unavailable();
  }

  Future<void> hasNumberFromClipboard() => _hasClipboardUseCase().then((hasNumber) {
      state = hasNumber == true
          ? ClipboardState.hasNumber()
          : ClipboardState.unavailable();
    });
}

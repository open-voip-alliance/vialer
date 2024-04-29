import 'package:dartx/dartx.dart';
import 'package:vialer/data/repositories/clipboard/clipboard_repository.dart';
import 'package:vialer/dependency_locator.dart';

import '../../util/numberic_strings.dart';
import '../use_case.dart';

class GetPhoneNumberFromClipboardUseCase extends UseCase {
  final _clipboardRepository = dependencyLocator<ClipboardRepository>();

  Future<String?> call() async {
    final text = await _clipboardRepository.getClipboardText();

    if (text == null) return null;

    final sanitizedText = _sanitizePhoneNumber(text);

    return sanitizedText.isNumeric() ? sanitizedText : null;
  }

  static const _ignoredCharacters = [')', '(', '-', ' '];

  String _sanitizePhoneNumber(String text) => text
      .split('')
      .filter((element) => !_ignoredCharacters.contains(element))
      .join('')
      .replaceFirst('+', '00');
}

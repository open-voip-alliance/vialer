import 'package:vialer/data/repositories/clipboard/clipboard_repository.dart';
import 'package:vialer/dependency_locator.dart';

import '../use_case.dart';
import '../../util/numberic_strings.dart';

class GetPhoneNumberFromClipboardUseCase extends UseCase {
  final _clipboardRepository = dependencyLocator<ClipboardRepository>();

  Future<String?> call() async {
    final text = await _clipboardRepository.getClipboardText();

    if (text != null) {
      String sanitizedText = _sanitizePhoneNumber(text);
      if (sanitizedText.isNumeric()) {
        return sanitizedText;
      }
    }

    return null;
  }

  String _sanitizePhoneNumber(String text) {
    String sanitized = text.replaceAll(' ', '');
    sanitized = sanitized.replaceFirst('+', '00');
    return sanitized;
  }
}

import 'package:vialer/data/repositories/clipboard/clipboard_repository.dart';
import 'package:vialer/dependency_locator.dart';

import '../use_case.dart';
import '../../util/numberic_strings.dart';

class GetNumberFromClipboardUseCase extends UseCase {
  final _clipboardRepository = dependencyLocator<ClipBoardRepository>();

  Future<String?> call() async {
    final text = await _clipboardRepository.getClipboardText();
    print("Clipboard text: $text");

    if (text != null && text.isNumeric()) {
      print("2");
      return text;
    }

    return null;
  }
}

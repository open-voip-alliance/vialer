import 'package:vialer/data/repositories/clipboard/clipboard_repository.dart';
import 'package:vialer/dependency_locator.dart';

import '../use_case.dart';

class HasNumberFromClipboardUseCase extends UseCase {
  final _clipboardRepository = dependencyLocator<ClipBoardRepository>();

  Future<bool?> call() => _clipboardRepository.hasNumberInClipboard();
}

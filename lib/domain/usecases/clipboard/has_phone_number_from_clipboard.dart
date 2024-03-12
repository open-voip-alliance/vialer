import 'package:vialer/data/repositories/clipboard/clipboard_repository.dart';
import 'package:vialer/dependency_locator.dart';

import '../use_case.dart';

class HasPhoneNumberFromClipboardUseCase extends UseCase {
  final _clipboardRepository = dependencyLocator<ClipboardRepository>();

  Future<bool> call() => _clipboardRepository.hasPhoneNumberInClipboard();
}

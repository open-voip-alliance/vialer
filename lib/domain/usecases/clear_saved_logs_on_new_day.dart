import 'dart:async';

import '../../dependency_locator.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class ClearSavedLogsOnNewDayUseCase extends FutureUseCase<void> {
  final _storageRepository = dependencyLocator<StorageRepository>();

  @override
  Future<void> call() async {
    final lastLog = _storageRepository.logs?.split('\n')?.last;
    if (lastLog == null) {
      return;
    }

    final match = RegExp(r'\[(.+)\]').firstMatch(lastLog);
    if (match == null) {
      return;
    }

    final dateTimeString = match.groupCount >= 1 ? match.group(1) : null;
    if (dateTimeString == null) {
      return;
    }

    final date = DateTime.parse(dateTimeString);
    final now = DateTime.now();

    if (date.day != now.day) {
      _storageRepository.logs = null;
    }
  }
}

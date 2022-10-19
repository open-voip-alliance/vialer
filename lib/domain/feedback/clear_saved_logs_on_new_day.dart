import 'dart:async';

import '../../dependency_locator.dart';
import '../legacy/storage.dart';
import '../use_case.dart';

class ClearSavedLogsOnNewDayUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  Future<void> call() async {
    final lastLog = _storageRepository.logs?.split('\n').last;

    if (_shouldLogsBeCleared(lastLog)) {
      _storageRepository.logs = null;
    }
  }

  bool _shouldLogsBeCleared(String? lastLog) {
    if (lastLog == null) {
      return false;
    }

    final match = RegExp(r'\[(.+)\]').firstMatch(lastLog);

    if (match == null) {
      return false;
    }

    final dateTimeString = match.groupCount >= 1 ? match.group(1) : null;

    if (dateTimeString == null) {
      return false;
    }

    try {
      final date = DateTime.parse(dateTimeString);
      final now = DateTime.now();

      return date.day != now.day;
    } on FormatException {
      return false;
    }
  }
}

import '../../dependency_locator.dart';
import '../use_case.dart';
import 'logging_repository.dart';

/// Remove any logs that are currently stored in the databases.
class RemoveStoredLogs extends UseCase {
  late final _loggingRepository = dependencyLocator<LoggingRepository>();

  Future<void> call({required bool keepPastDay}) async {
    final before = keepPastDay
        ? DateTime.now().subtract(const Duration(days: 1))
        : DateTime.now();

    _loggingRepository.remove(
      before: before,
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dependency_locator.dart';
import '../../../domain/logging/logging_repository.dart';
import '../../../domain/logging/remote_logging/upload_pending_remote_logs.dart';
import 'state.dart';

export 'state.dart';

class LogUploaderCubit extends Cubit<LogUploaderState> {
  final _loggingRepository = dependencyLocator<LoggingRepository>();

  LogUploaderCubit() : super(NotUploadingLogs()) {
    _loggingRepository.watch().then(
          (value) => value.listen((_) => upload()),
        );
  }

  void upload() async {
    emit(UploadingLogs());
    await UploadPendingRemoteLogs()();
    emit(NotUploadingLogs());
  }
}

import 'dart:async';
import 'dart:io';

import '../../app/util/pigeon.dart';
import '../use_case.dart';

class CheckAppUpdatesUseCase extends UseCase {
  Future<bool> call() async {
    if (Platform.isAndroid) {
      final onUpdateTypeKnownCompleter = Completer<bool>();
      final onDownloadedCompleter = Completer<void>();

      AndroidFlexibleUpdateHandler.setup(
        _AndroidFlexibleUpdateHandler(
          onUpdateTypeKnown: onUpdateTypeKnownCompleter.complete,
          onDownloaded: onDownloadedCompleter.complete,
        ),
      );

      AppUpdates().check();

      final isFlexible = await onUpdateTypeKnownCompleter.future;

      if (isFlexible) {
        await onDownloadedCompleter.future;
        return true;
      }
    }

    return false;
  }
}

class _AndroidFlexibleUpdateHandler implements AndroidFlexibleUpdateHandler {
  final void Function(bool) _onUpdateTypeKnown;
  final void Function() _onDownloaded;

  const _AndroidFlexibleUpdateHandler({
    required void Function(bool) onUpdateTypeKnown,
    required void Function() onDownloaded,
  })  : _onUpdateTypeKnown = onUpdateTypeKnown,
        _onDownloaded = onDownloaded;

  @override
  void onUpdateTypeKnown(bool isFlexible) => _onUpdateTypeKnown(isFlexible);

  @override
  void onDownloaded() => _onDownloaded();
}

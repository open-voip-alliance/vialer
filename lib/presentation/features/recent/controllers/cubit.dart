import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/call_records/call_record.dart';
import '../../../../../data/repositories/call_records/client/local_client_calls.dart';
import '../../../../../dependency_locator.dart';
import '../../../../../domain/usecases/call_records/client/get_recent_client_calls.dart';
import '../../../../../domain/usecases/call_records/client/import_new_client_calls.dart';
import '../../../../../domain/usecases/call_records/personal/get_recent_calls.dart';
import '../../../../../domain/usecases/metrics/track_copy_number.dart';
import '../../../shared/controllers/caller/cubit.dart';
import 'state.dart';

export 'state.dart';

class RecentCallsCubit extends Cubit<RecentCallsState> {
  RecentCallsCubit(this._caller) : super(const LoadingInitialRecentCalls()) {
    unawaited(_loadRecentCalls(page: 1));
  }

  @protected
  final getRecentCalls = GetRecentCallsUseCase();

  final _trackCopyNumber = TrackCopyNumberUseCase();

  final CallerCubit _caller;

  Future<void> requestPermission() async {
    await _caller.requestPermission();
  }

  Future<void> call(String destination) =>
      _caller.call(destination, origin: CallOrigin.recents);

  void copyNumber(String number) {
    _trackCopyNumber();

    unawaited(Clipboard.setData(ClipboardData(text: number)));
  }

  bool onlyMissedCalls = false;

  Future<void> refreshRecentCalls() async {
    emit(RefreshingRecentCalls(state.callRecords, state.page));

    await _loadRecentCalls(page: 1);
  }

  Future<void> loadMoreRecentCalls() async {
    if (state is RecentCallsLoaded && !state.maxPagesLoaded) {
      emit(LoadingMoreRecentCalls(state.callRecords, state.page));

      await _loadRecentCalls(page: state.page + 1);
    }
  }

  Future<void> performBackgroundImport() async {
    // Personal calls require API calls so there is never any background
    // import.
  }

  Future<void> _loadRecentCalls({required int page}) async {
    final newlyFetchedCalls = await _fetch(page: page);
    final existingCalls = state.callRecords.keepRecordsIfNecessary(page);

    List<CallRecord> calls;

    if (state is LoadingMoreRecentCalls) {
      calls = [
        ...existingCalls,
        ...newlyFetchedCalls,
      ];
    } else {
      calls = [
        ...newlyFetchedCalls,
        ...existingCalls,
      ];
    }

    calls =
        calls.distinct().sortedByDescending((record) => record.date).toList();

    emit(RecentCallsLoaded(calls, page));
  }

  Future<List<CallRecord>> _fetch({required int page}) =>
      getRecentCalls(page: page, onlyMissedCalls: onlyMissedCalls);
}

class ClientCallsCubit extends RecentCallsCubit {
  ClientCallsCubit(super.caller) {
    unawaited(
      _localClientCalls.watch().then(
            (value) => value.listen(
              (event) {
                refreshRecentCalls();
              },
            ),
          ),
    );
  }

  final _getRecentClientCalls =
      dependencyLocator<GetRecentClientCallsUseCase>();
  final _importNewClientCalls = ImportNewClientCallRecordsUseCase();
  final _localClientCalls = dependencyLocator<LocalClientCallsRepository>();

  @override
  Future<List<ClientCallRecordWithContact>> _fetch({required int page}) =>
      _getRecentClientCalls(
        page: page,
        onlyMissedCalls: onlyMissedCalls,
      );

  @override
  Future<void> performBackgroundImport() => _importNewClientCalls();

  @override
  Future<void> refreshRecentCalls() async {
    emit(RefreshingRecentCalls(state.callRecords, state.page));

    await _loadRecentCalls(page: 1);
  }

  @override
  Future<void> _loadRecentCalls({required int page}) async {
    final newlyFetchedCalls = await _fetch(page: page);
    final existingCalls = state.callRecords.keepRecordsIfNecessary(page);

    final calls = (existingCalls + newlyFetchedCalls)
        .distinct()
        .sortedByDescending((record) => record.date)
        .toList();

    emit(RecentCallsLoaded(calls, page));
  }
}

extension on List<CallRecord> {
  /// We will discard our existing call records if we are ever loading from
  /// the first page. We only need to retain them if we are loading future
  /// pages.
  List<CallRecord> keepRecordsIfNecessary(int page) => page == 1 ? [] : this;
}

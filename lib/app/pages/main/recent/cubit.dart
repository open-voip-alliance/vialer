import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../dependency_locator.dart';
import '../../../../domain/entities/call_record.dart';
import '../../../../domain/entities/client_call_record.dart';
import '../../../../domain/repositories/local_client_calls.dart';
import '../../../../domain/usecases/client_calls/import_new_client_calls.dart';
import '../../../../domain/usecases/get_recent_calls.dart';
import '../../../../domain/usecases/get_recent_client_calls.dart';
import '../../../../domain/usecases/metrics/track_copy_number.dart';
import '../widgets/caller/cubit.dart';
import 'state.dart';

export 'state.dart';

class RecentCallsCubit extends Cubit<RecentCallsState> {
  @protected
  final getRecentCalls = GetRecentCallsUseCase();

  final _trackCopyNumber = TrackCopyNumberUseCase();

  final CallerCubit _caller;

  bool _currentlyLoadedOnlyMissedCalls = false;

  RecentCallsCubit(this._caller) : super(const LoadingInitialRecentCalls()) {
    _loadRecentCalls(page: 1);
  }

  Future<void> requestPermission() async {
    await _caller.requestPermission();
  }

  Future<void> call(String destination) async {
    _caller.call(destination, origin: CallOrigin.recents);
  }

  void copyNumber(String number) {
    _trackCopyNumber();

    Clipboard.setData(ClipboardData(text: number));
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
    final existingCalls = _currentlyLoadedOnlyMissedCalls == onlyMissedCalls
        ? state.callRecords
        : <CallRecord>[];
    _currentlyLoadedOnlyMissedCalls = onlyMissedCalls;
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

  Future<List<CallRecord>> _fetch({required int page}) async =>
      await getRecentCalls(page: page, onlyMissedCalls: onlyMissedCalls);
}

class ClientCallsCubit extends RecentCallsCubit {
  final _getRecentClientCalls = GetRecentClientCallsUseCase();
  final _importNewClientCalls = ImportNewClientCallRecordsUseCase();
  final _localClientCalls = dependencyLocator<LocalClientCallsRepository>();

  ClientCallsCubit(CallerCubit caller) : super(caller) {
    _localClientCalls.watch().then((value) => value.listen((event) {
          refreshRecentCalls();
        }));
  }

  @override
  Future<List<ClientCallRecord>> _fetch({required int page}) async {
    return await _getRecentClientCalls(
      page: page,
      onlyMissedCalls: onlyMissedCalls,
    );
  }

  @override
  Future<void> performBackgroundImport() async {
    _importNewClientCalls();
  }

  @override
  Future<void> refreshRecentCalls() async {
    emit(RefreshingRecentCalls(state.callRecords, state.page));

    await _loadRecentCalls(page: 1);
  }

  @override
  Future<void> _loadRecentCalls({required int page}) async {
    final newlyFetchedCalls = await _fetch(page: page);
    final existingCalls = _currentlyLoadedOnlyMissedCalls == onlyMissedCalls
        ? state.callRecords.toList()
        : <CallRecord>[];
    _currentlyLoadedOnlyMissedCalls = onlyMissedCalls;

    final calls = (existingCalls + newlyFetchedCalls)
        .distinct()
        .sortedByDescending((record) => record.date)
        .toList();

    emit(RecentCallsLoaded(calls, page));
  }
}

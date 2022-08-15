import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/call_record_with_contact.dart';
import '../../../../domain/usecases/client_calls/import_historic_client_call_records.dart';
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

  Future<void> _loadRecentCalls({required int page}) async {
    final recentCalls = await _fetch(page: page);
    List<CallRecordWithContact> currentCalls;

    if (state is LoadingMoreRecentCalls) {
      currentCalls = [
        ...state.callRecords,
        ...recentCalls,
      ];
    } else {
      currentCalls = [
        ...recentCalls,
        ...state.callRecords,
      ];
    }

    emit(RecentCallsLoaded(currentCalls.distinct().toList(), page));
  }

  Future<List<CallRecordWithContact>> _fetch({required int page}) async =>
      await getRecentCalls(page: page, onlyMissedCalls: onlyMissedCalls);
}

class ClientCallsCubit extends RecentCallsCubit {
  final _getRecentClientCalls = GetRecentClientCallsUseCase();
  final _importNewClientCalls = ImportNewClientCallRecordsUseCase();
  final _importHistoricClientCalls = ImportHistoricClientCallRecordsUseCase();

  bool _firstRun;

  bool awaitImport = true;

  ClientCallsCubit(
    CallerCubit caller, {
    required bool firstRun,
  })  : _firstRun = firstRun,
        super(caller);

  @override
  Future<List<CallRecordWithContact>> _fetch({required int page}) async {
    final import = _firstRun && page == 1
        ? _importHistoricClientCalls()
        : _importNewClientCalls();

    _firstRun = false;

    if (awaitImport) {
      await import;
    }

    // awaitImport is reset so that the next run will await import
    // (unless it's set to false again before fetching).
    awaitImport = true;

    return await _getRecentClientCalls(
      page: page,
      onlyMissedCalls: onlyMissedCalls,
    );
  }
}

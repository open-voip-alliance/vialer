import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/call_record_with_contact.dart';
import '../../../../domain/usecases/get_recent_calls.dart';
import '../../../../domain/usecases/metrics/track_copy_number.dart';
import '../widgets/caller/cubit.dart';
import 'state.dart';

export 'state.dart';

class RecentCallsCubit extends Cubit<RecentCallsState> {
  final _getRecentCalls = GetRecentCallsUseCase();
  final _trackCopyNumber = TrackCopyNumberUseCase();

  final CallerCubit _caller;

  RecentCallsCubit(this._caller) : super(LoadingInitialRecentCalls()) {
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

  Future<void> refreshRecentCalls() async {
    emit(RefreshingRecentCalls(state.callRecords, state.page));

    _loadRecentCalls(page: 1);
  }

  Future<void> loadMoreRecentCalls() async {
    if (state is RecentCallsLoaded && !state.maxPagesLoaded) {
      emit(LoadingMoreRecentCalls(state.callRecords, state.page));

      _loadRecentCalls(page: state.page + 1);
    }
  }

  Future<void> _loadRecentCalls({required int page}) async {
    final recentCalls = await _getRecentCalls(page: page);
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
}

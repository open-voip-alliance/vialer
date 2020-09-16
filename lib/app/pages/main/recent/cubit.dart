import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:dartx/dartx.dart';

import '../widgets/caller/cubit.dart';

import '../../../../domain/entities/call_with_contact.dart';
import '../../../../domain/usecases/get_recent_calls.dart';

import '../../../util/debug.dart';

import 'state.dart';
export 'state.dart';

class RecentCallsCubit extends Cubit<RecentCallsState> {
  final _getRecentCalls = GetRecentCallsUseCase();

  final CallerCubit _caller;

  RecentCallsCubit(this._caller) : super(LoadingInitialRecentCalls()) {
    _loadRecentCalls(page: 0);
  }

  Future<void> call(String destination) async {
    doIfNotDebug(() {
      Segment.track(eventName: 'call', properties: {'via': 'recents'});
    });

    _caller.call(destination);
  }

  void copyNumber(String number) {
    doIfNotDebug(() {
      Segment.track(eventName: 'copy-number');
    });

    Clipboard.setData(ClipboardData(text: number));
  }

  Future<void> refreshRecentCalls() async {
    emit(RefreshingRecentCalls(state.calls, state.page));

    _loadRecentCalls(page: 0);
  }

  Future<void> loadMoreRecentCalls() async {
    if (state is RecentCallsLoaded && !state.maxPagesLoaded) {
      emit(LoadingMoreRecentCalls(state.calls, state.page));

      _loadRecentCalls(page: state.page + 1);
    }
  }

  Future<void> _loadRecentCalls({@required int page}) async {
    final recentCalls = await _getRecentCalls(page: page);
    List<CallWithContact> currentCalls;

    if (state is LoadingMoreRecentCalls) {
      currentCalls = [
        ...state.calls,
        ...recentCalls,
      ];
    } else {
      currentCalls = [
        ...recentCalls,
        ...state.calls,
      ];
    }

    emit(RecentCallsLoaded(currentCalls.distinct().toList(), page));
  }
}

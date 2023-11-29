import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../domain/call_records/call_record.dart';

part 'state.freezed.dart';

@freezed
sealed class RecentCallsState with _$RecentCallsState {
  const RecentCallsState._();
  const factory RecentCallsState.loadingInitialRecentCalls([
    @Default([]) List<CallRecord> callRecords,
    @Default(1) int page,
  ]) = LoadingInitialRecentCalls;
  const factory RecentCallsState.refreshingRecentCalls(
    List<CallRecord> callRecords,
    int page,
  ) = RefreshingRecentCalls;
  const factory RecentCallsState.loadingMoreRecentCalls(
    List<CallRecord> callRecords,
    int page,
  ) = LoadingMoreRecentCalls;
  const factory RecentCallsState.recentCallsLoaded(
    List<CallRecord> callRecords,
    int page,
  ) = RecentCallsLoaded;

  static const _maxPages = 10;

  bool get maxPagesLoaded => page == _maxPages;
}

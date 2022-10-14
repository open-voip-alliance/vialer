import 'package:equatable/equatable.dart';

import '../../../../domain/call_records/call_record.dart';

abstract class RecentCallsState extends Equatable {
  final List<CallRecord> callRecords;

  final int page;

  final maxPages = 10;

  bool get maxPagesLoaded => page == maxPages;

  const RecentCallsState(this.callRecords, this.page);

  @override
  List<Object?> get props => [callRecords, page];
}

class LoadingInitialRecentCalls extends RecentCallsState {
  const LoadingInitialRecentCalls() : super(const [], 1);
}

class RefreshingRecentCalls extends RecentCallsState {
  const RefreshingRecentCalls(
    List<CallRecord> callRecords,
    int page,
  ) : super(callRecords, page);
}

class LoadingMoreRecentCalls extends RecentCallsState {
  const LoadingMoreRecentCalls(
    List<CallRecord> callRecords,
    int page,
  ) : super(callRecords, page);
}

class RecentCallsLoaded extends RecentCallsState {
  const RecentCallsLoaded(List<CallRecord> callRecords, int page)
      : super(callRecords, page);
}

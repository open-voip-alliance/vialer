import 'package:equatable/equatable.dart';

import '../../../../domain/entities/call_record_with_contact.dart';

abstract class RecentCallsState extends Equatable {
  final List<CallRecordWithContact> calls;

  final int page;

  final maxPages = 2; // 3 months in total.

  bool get maxPagesLoaded => page == maxPages;

  RecentCallsState(this.calls, this.page);

  @override
  List<Object?> get props => [calls, page];
}

class LoadingInitialRecentCalls extends RecentCallsState {
  LoadingInitialRecentCalls() : super([], 1);
}

class RefreshingRecentCalls extends RecentCallsState {
  RefreshingRecentCalls(
    List<CallRecordWithContact> calls,
    int page,
  ) : super(calls, page);
}

class LoadingMoreRecentCalls extends RecentCallsState {
  LoadingMoreRecentCalls(
    List<CallRecordWithContact> calls,
    int page,
  ) : super(calls, page);
}

class RecentCallsLoaded extends RecentCallsState {
  RecentCallsLoaded(List<CallRecordWithContact> calls, int page)
      : super(calls, page);
}

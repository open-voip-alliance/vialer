import 'package:equatable/equatable.dart';

import '../../../../domain/entities/call_with_contact.dart';

abstract class RecentCallsState extends Equatable {
  final List<CallWithContact> calls;

  final int page;

  final maxPages = 2; // 3 months in total.

  bool get maxPagesLoaded => page == maxPages;

  RecentCallsState(this.calls, this.page);

  @override
  List<Object> get props => [calls, page];
}

class LoadingInitialRecentCalls extends RecentCallsState {
  LoadingInitialRecentCalls() : super([], 0);
}

class RefreshingRecentCalls extends RecentCallsState {
  RefreshingRecentCalls(
    List<CallWithContact> calls,
    int page,
  ) : super(calls, page);
}

class LoadingMoreRecentCalls extends RecentCallsState {
  LoadingMoreRecentCalls(
    List<CallWithContact> calls,
    int page,
  ) : super(calls, page);
}

class RecentCallsLoaded extends RecentCallsState {
  RecentCallsLoaded(List<CallWithContact> calls, int page) : super(calls, page);
}

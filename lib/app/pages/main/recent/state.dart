import 'package:equatable/equatable.dart';

import '../../../../domain/entities/call.dart';

abstract class RecentCallsState extends Equatable {
  final List<Call> calls;

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
  RefreshingRecentCalls(List<Call> calls, pages) : super(calls, pages);
}

class LoadingMoreRecentCalls extends RecentCallsState {
  LoadingMoreRecentCalls(List<Call> calls, pages) : super(calls, pages);
}

class RecentCallsLoaded extends RecentCallsState {
  RecentCallsLoaded(List<Call> calls, pages) : super(calls, pages);
}

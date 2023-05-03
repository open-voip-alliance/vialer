import 'package:equatable/equatable.dart';

import '../../../../domain/call_records/call_record.dart';

abstract class RecentCallsState extends Equatable {
  const RecentCallsState(this.callRecords, this.page);

  final List<CallRecord> callRecords;

  final int page;

  static const _maxPages = 10;

  bool get maxPagesLoaded => page == _maxPages;

  @override
  List<Object?> get props => [callRecords, page];
}

class LoadingInitialRecentCalls extends RecentCallsState {
  const LoadingInitialRecentCalls() : super(const [], 1);
}

class RefreshingRecentCalls extends RecentCallsState {
  const RefreshingRecentCalls(
    super.callRecords,
    super.page,
  );
}

class LoadingMoreRecentCalls extends RecentCallsState {
  const LoadingMoreRecentCalls(
    super.callRecords,
    super.page,
  );
}

class RecentCallsLoaded extends RecentCallsState {
  const RecentCallsLoaded(super.callRecords, super.page);
}

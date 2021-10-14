import 'package:equatable/equatable.dart';

import '../../../../domain/entities/call_record_with_contact.dart';

abstract class RecentCallsState extends Equatable {
  final List<CallRecordWithContact> callRecords;

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
    List<CallRecordWithContact> callRecords,
    int page,
  ) : super(callRecords, page);
}

class LoadingMoreRecentCalls extends RecentCallsState {
  const LoadingMoreRecentCalls(
    List<CallRecordWithContact> callRecords,
    int page,
  ) : super(callRecords, page);
}

class RecentCallsLoaded extends RecentCallsState {
  const RecentCallsLoaded(List<CallRecordWithContact> callRecords, int page)
      : super(callRecords, page);
}

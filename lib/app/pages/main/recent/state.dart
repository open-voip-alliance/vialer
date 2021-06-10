import 'package:equatable/equatable.dart';

import '../../../../domain/entities/call_record_with_contact.dart';

abstract class RecentCallsState extends Equatable {
  final List<CallRecordWithContact> callRecords;

  final int page;

  final maxPages = 2; // 3 months in total.

  bool get maxPagesLoaded => page == maxPages;

  RecentCallsState(this.callRecords, this.page);

  @override
  List<Object?> get props => [callRecords, page];
}

class LoadingInitialRecentCalls extends RecentCallsState {
  LoadingInitialRecentCalls() : super([], 1);
}

class RefreshingRecentCalls extends RecentCallsState {
  RefreshingRecentCalls(
    List<CallRecordWithContact> callRecords,
    int page,
  ) : super(callRecords, page);
}

class LoadingMoreRecentCalls extends RecentCallsState {
  LoadingMoreRecentCalls(
    List<CallRecordWithContact> callRecords,
    int page,
  ) : super(callRecords, page);
}

class RecentCallsLoaded extends RecentCallsState {
  RecentCallsLoaded(List<CallRecordWithContact> callRecords, int page)
      : super(callRecords, page);
}

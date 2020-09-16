import 'dart:async';

import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../entities/call_with_contact.dart';
import '../repositories/recent_call.dart';
import '../use_case.dart';

class GetRecentCallsUseCase extends FutureUseCase<List<CallWithContact>> {
  final _recentCallRepository = dependencyLocator<RecentCallRepository>();

  @override
  Future<List<CallWithContact>> call({@required int page}) =>
      _recentCallRepository.getRecentCalls(page: page);
}

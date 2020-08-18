import 'dart:async';

import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../entities/call.dart';
import '../repositories/recent_call.dart';
import '../use_case.dart';

class GetRecentCallsUseCase extends FutureUseCase<List<Call>> {
  final _recentCallRepository = dependencyLocator<RecentCallRepository>();

  @override
  Future<List<Call>> call({@required int page}) =>
      _recentCallRepository.getRecentCalls(page: page);
}

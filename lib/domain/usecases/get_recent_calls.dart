import 'dart:async';

import 'package:meta/meta.dart';

import '../entities/call.dart';
import '../repositories/recent_call.dart';
import '../use_case.dart';

class GetRecentCallsUseCase extends FutureUseCase<List<Call>> {
  final RecentCallRepository _recentCallRepository;

  GetRecentCallsUseCase(this._recentCallRepository);

  @override
  Future<List<Call>> call({@required int page}) =>
      _recentCallRepository.getRecentCalls(page: page);
}

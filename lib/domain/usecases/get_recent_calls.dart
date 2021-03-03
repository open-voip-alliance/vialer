import 'dart:async';

import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../entities/call_with_contact.dart';
import '../repositories/recent_call.dart';
import '../use_case.dart';
import 'get_user.dart';

class GetRecentCallsUseCase extends FutureUseCase<List<CallWithContact>> {
  final _recentCallRepository = dependencyLocator<RecentCallRepository>();

  final _getUser = GetUserUseCase();

  @override
  Future<List<CallWithContact>> call({@required int page}) async {
    final user = await _getUser(latest: false);

    return _recentCallRepository.getRecentCalls(
      page: page,
      outgoingNumber: user.outgoingCli,
    );
  }
}

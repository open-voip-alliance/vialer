import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../entities/recent_call.dart';
import '../repositories/recent_call_repository.dart';

class GetRecentCallsUseCase extends UseCase<List<RecentCall>, void> {
  final RecentCallRepository _recentCallRepository;

  GetRecentCallsUseCase(this._recentCallRepository);

  @override
  Future<Stream<List<RecentCall>>> buildUseCaseStream(_) async {
    final controller = StreamController<List<RecentCall>>();

    controller.add(await _recentCallRepository.getRecentCalls());
    controller.close();

    return controller.stream;
  }
}

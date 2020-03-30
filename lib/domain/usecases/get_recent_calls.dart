import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../entities/call.dart';
import '../repositories/recent_call.dart';

class GetRecentCallsUseCase
    extends UseCase<List<Call>, GetRecentCallsUseCaseParams> {
  final RecentCallRepository _recentCallRepository;

  GetRecentCallsUseCase(this._recentCallRepository);

  @override
  Future<Stream<List<Call>>> buildUseCaseStream(
    GetRecentCallsUseCaseParams params,
  ) async {
    final controller = StreamController<List<Call>>();

    controller.add(
      await _recentCallRepository.getRecentCalls(
        page: params.page,
      ),
    );
    unawaited(controller.close());

    return controller.stream;
  }
}

class GetRecentCallsUseCaseParams {
  final int page;

  GetRecentCallsUseCaseParams({@required this.page});
}

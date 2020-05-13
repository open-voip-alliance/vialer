import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../entities/build_info.dart';
import '../repositories/build_info.dart';

class GetBuildInfoUseCase extends UseCase<BuildInfo, void> {
  final BuildInfoRepository _buildInfoRepository;

  GetBuildInfoUseCase(this._buildInfoRepository);

  @override
  Future<Stream<BuildInfo>> buildUseCaseStream(_) async {
    final controller = StreamController<BuildInfo>();

    controller.add(await _buildInfoRepository.getBuildInfo());
    unawaited(controller.close());

    return controller.stream;
  }
}

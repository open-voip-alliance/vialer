import 'package:freezed_annotation/freezed_annotation.dart';

part 'build_info.freezed.dart';

@freezed
class BuildInfo with _$BuildInfo {
  const factory BuildInfo({
    required String version,
    String? buildNumber,
    String? mergeRequestNumber,
    String? branchName,
    String? tag,
    required String packageName,
    required bool isProduction,
  }) = _BuildInfo;
}

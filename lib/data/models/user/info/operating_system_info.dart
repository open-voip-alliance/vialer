import 'package:freezed_annotation/freezed_annotation.dart';

part 'operating_system_info.freezed.dart';

@freezed
class OperatingSystemInfo with _$OperatingSystemInfo {
  const factory OperatingSystemInfo({
    required String version,
  }) = _OperatingSystemInfo;
}

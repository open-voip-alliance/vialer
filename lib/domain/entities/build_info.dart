import 'package:meta/meta.dart';

class BuildInfo {
  final String version;
  final String buildNumber;
  final String mergeRequestNumber;
  final String branchName;

  const BuildInfo({
    @required this.version,
    this.buildNumber,
    this.mergeRequestNumber,
    this.branchName,
  });
}

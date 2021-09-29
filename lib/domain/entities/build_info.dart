class BuildInfo {
  final String version;
  final String? buildNumber;
  final String? mergeRequestNumber;
  final String? branchName;
  final String? tag;
  final String packageName;

  const BuildInfo({
    required this.version,
    this.buildNumber,
    this.mergeRequestNumber,
    this.branchName,
    this.tag,
    required this.packageName,
  });
}

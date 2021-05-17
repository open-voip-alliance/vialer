class BuildInfo {
  final String version;
  final String? buildNumber;
  final String? mergeRequestNumber;
  final String? branchName;
  final String packageName;

  const BuildInfo({
    required this.version,
    this.buildNumber,
    this.mergeRequestNumber,
    this.branchName,
    required this.packageName,
  });
}

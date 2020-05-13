import 'package:meta/meta.dart';

class BuildInfo {
  final String version;
  final String commit;

  BuildInfo({
    @required this.version,
    this.commit,
  });
}

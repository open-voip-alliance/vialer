import '../entities/build_info.dart';

// ignore: one_member_abstracts
abstract class BuildInfoRepository {
  Future<BuildInfo> getBuildInfo();
}

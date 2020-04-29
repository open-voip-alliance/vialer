abstract class EnvRepository {
  Future<String> get sentryDsn;

  Future<String> get logentriesAndroidToken;

  Future<String> get logentriesIosToken;
}

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/repositories/env.dart';

class DeviceEnvRepository extends EnvRepository {
  static const _sentrDsnKey = 'SENTRY_DSN';

  Map<String, String> __env;

  Future<Map<String, String>> get _env async {
    if (__env == null) {
      await DotEnv().load();
      __env = DotEnv().env;
    }

    return __env;
  }

  @override
  Future<String> get sentryDsn async {
    final env = await _env;

    return env[_sentrDsnKey];
  }
}

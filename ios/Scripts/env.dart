import '../../utils/env_utils.dart';

import 'util.dart';

Future<void> main() async {
  await writeXconfigFile(
    name: 'Env',
    values: await readEnv('${root.path}/../.env'),
  );
}

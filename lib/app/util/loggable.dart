import 'package:logging/logging.dart';

mixin Loggable {
  late final Logger logger = Logger('@$runtimeType');
}

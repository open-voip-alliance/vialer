import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

mixin Loggable {
  Logger _logger;

  @protected
  Logger get logger => _logger ??= Logger('@$runtimeType');
}

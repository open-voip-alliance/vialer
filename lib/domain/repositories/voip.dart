import 'package:logging/logging.dart';
import 'package:voip_flutter_integration/voip_flutter_integration.dart';

import '../../app/util/loggable.dart';
import '../entities/phone_account.dart';

class VoipRepository with Loggable {
  Fil _fil;

  Future<void> start(PhoneAccount appAccount) async {
    _fil = await startFil(
      (builder) {
        builder
          ..auth = Auth(
            username: appAccount.accountId.toString(),
            password: appAccount.password,
            // TODO: Use different domain when encryption is disabled
            domain: 'sip.encryptedsip.com',
            port: 5061,
            secure: true,
          )
          ..preferences = const Preferences(
            codecs: Codec.values,
            useApplicationProvidedRingtone: false,
          );

        return ApplicationSetup(
          logger: (msg, level) => logger.log(level.toLoggerLevel(), msg),
          // TODO: Base on brand
          userAgent: 'Voys Freedom',
        );
      },
    );
  }

  Future<void> call(String number) => _fil.call(number);

  Future<FilCall> get activeCall => _fil.calls.active;

  Future<void> endCall() => _fil.actions.end();

  Stream<Event> get events => _fil.events;
}

extension on LogLevel {
  Level toLoggerLevel() {
    if (this == LogLevel.debug) {
      return Level.FINE;
    } else if (this == LogLevel.info) {
      return Level.INFO;
    } else if (this == LogLevel.warning) {
      return Level.WARNING;
    } else if (this == LogLevel.error) {
      return Level.SEVERE;
    } else {
      throw UnsupportedError('Unknown LogLevel: $this');
    }
  }
}

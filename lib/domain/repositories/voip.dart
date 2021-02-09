import 'package:voip_flutter_integration/voip_flutter_integration.dart';

import '../entities/phone_account.dart';

class VoipRepository {
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
          logger: (msg, level) => print(
            'FIL: [${level.toString().split('.')[1]}] $msg',
          ),
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

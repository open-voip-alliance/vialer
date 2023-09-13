import '../../calling/outgoing_number/outgoing_number.dart';
import '../../calling/voip/destination.dart';
import 'settings.dart';

enum CallSetting<T extends Object> with SettingKey<T> {
  useVoip<bool>(),
  outgoingNumber<OutgoingNumber>(
    Converters(
      OutgoingNumber.serializeToJson,
      OutgoingNumber.fromJson,
    ),
  ),
  mobileNumber<String>(),
  dnd<bool>(),
  usePhoneRingtone<bool>(),
  destination<Destination>(
    Converters(
      Destination.serializeToJson,
      Destination.fromJson,
    ),
  ),

  /// If set to `true` the user has decided they want incoming calls to
  /// fallback to their configured mobile number, via a GSM call.
  useMobileNumberAsFallback<bool>();

  const CallSetting([this.valueJsonConverter]);

  @override
  final SettingValueJsonConverter<T>? valueJsonConverter;

  static const Map<CallSetting, bool> defaultValues = {
    CallSetting.useVoip: true,
    CallSetting.dnd: false,
    CallSetting.usePhoneRingtone: false,
    CallSetting.useMobileNumberAsFallback: false,
  };
}

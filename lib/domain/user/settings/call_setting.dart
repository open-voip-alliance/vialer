import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../calling/voip/destination.dart';
import 'settings.dart';

enum CallSetting<T extends Object> with SettingKey<T> {
  useVoip<bool>(),
  outgoingNumber<OutgoingNumber>(
    Converters(
      OutgoingNumber.toJson,
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

@immutable
abstract class OutgoingNumber {
  const factory OutgoingNumber(String value) = UnsuppressedOutgoingNumber;

  const factory OutgoingNumber.suppressed() = SuppressedOutgoingNumber;

  factory OutgoingNumber.fromJson(dynamic json) => json == _suppressed
      ? const SuppressedOutgoingNumber()
      : OutgoingNumber(json as String);
  static const _suppressed = 'suppressed';

  static String toJson(OutgoingNumber number) =>
      number is SuppressedOutgoingNumber
          ? _suppressed
          : (number as UnsuppressedOutgoingNumber).value;
}

class SuppressedOutgoingNumber implements OutgoingNumber {
  const SuppressedOutgoingNumber();

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) => other is SuppressedOutgoingNumber;

  @override
  String toString() => OutgoingNumber._suppressed;
}

class UnsuppressedOutgoingNumber extends Equatable implements OutgoingNumber {
  const UnsuppressedOutgoingNumber(this.value);

  final String value;

  @override
  String toString() => value;

  @override
  List<Object?> get props => [value];
}

extension OutgoingNumberExt on OutgoingNumber {
  bool get isSuppressed => this is SuppressedOutgoingNumber;

  /// Returns the `value` if this is an unsuppressed number,
  /// and empty otherwise.
  String get valueOrEmpty {
    final self = this;

    return self is UnsuppressedOutgoingNumber ? self.value : '';
  }
}

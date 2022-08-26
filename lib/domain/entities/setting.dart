// ignore_for_file: avoid_positional_boolean_parameters

import 'package:dartx/dartx.dart';
import 'package:meta/meta.dart';
import 'package:recase/recase.dart';

import 'audio_codec.dart';
import 'availability.dart';
import 'client_available_outgoing_numbers.dart';
import 'system_user.dart';
import 'voipgrid_permissions.dart';

@immutable
abstract class Setting<T> {
  static const _typeKey = 'type';
  static const _valueKey = 'value';

  final T value;

  final bool mutable;

  /// Whether the setting is external, meaning: The setting has a source that's
  /// not our local storage (the portal, VoIP library, etc.)
  final bool external;

  /// Whether or not the content of this setting is PII (Personally Identifiable
  /// Information). This will determine whether or not this setting should
  /// be stored off this device.
  ///
  /// Setting this to TRUE still results in an event to be tracked but not the
  /// data stored within.
  ///
  /// This only affects [String] settings, [bool] settings will always be
  /// tracked unless [shouldTrack] is FALSE.
  final bool isPii = true;

  /// Whether changing this setting should result in an event being sent
  /// to metrics.
  ///
  /// This should usually only be set to FALSE if it is being tracked elsewhere.
  final bool shouldTrack = true;

  const Setting(
    this.value, {
    this.mutable = true,
    this.external = false,
  });

  static const List<Setting> presets = [
    RemoteLoggingSetting.preset(),
    ShowDialerConfirmPopupSetting.preset(),
    ShowSurveysSetting.preset(),
    UseVoipSetting.preset(),
    ShowTroubleshootingSettingsSetting.preset(),
    UseEncryptionSetting.preset(),
    AudioCodecSetting.preset(),
    UsePhoneRingtoneSetting.preset(),
    ShowCallsInNativeRecentsSetting.preset(),
    AvailabilitySetting.preset(),
    ClientOutgoingNumbersSetting.preset(),
    DndSetting.preset(),
    ShowClientCallsSetting.preset(),
    VoipgridPermissionsSetting.preset(),
  ];

  /// The setting formatted as properties to submit to metrics, these
  /// should be overridden if the value of complex settings
  /// (i.e. non-bool/string settings) need to be submitted to metrics.
  Map<String, dynamic> get asMetricProperties {
    if (value is String) {
      return isPii ? {} : {'value': value};
    }

    if (value is bool) {
      return {'enabled': value};
    }

    return {};
  }

  String get asMetricKeyName => '${ReCase(runtimeType.toString()).snakeCase}';

  Map<String, dynamic> toJson() {
    return {
      _typeKey: runtimeType.toString(),
      _valueKey: value,
    };
  }

  static Setting? fromJson(Map<String, dynamic> json) {
    final type = json[_typeKey];
    final value = json[_valueKey];

    assert(type != null);
    assert(value != null);

    if (type == (RemoteLoggingSetting).toString()) {
      return RemoteLoggingSetting(value as bool);
    } else if (type == (ShowDialerConfirmPopupSetting).toString()) {
      return ShowDialerConfirmPopupSetting(value as bool);
    } else if (type == (ShowSurveysSetting).toString()) {
      return ShowSurveysSetting(value as bool);
    // ignore: deprecated_member_use_from_same_package
    } else if (type == (BusinessNumberSetting).toString() ||
        type == (OutgoingNumberSetting).toString()) {
      return OutgoingNumberSetting(value as String);
    } else if (type == (MobileNumberSetting).toString()) {
      return MobileNumberSetting(value as String);
    } else if (type == (ShowTroubleshootingSettingsSetting).toString()) {
      return ShowTroubleshootingSettingsSetting(value as bool);
    } else if (type == (UseEncryptionSetting).toString()) {
      return UseEncryptionSetting(value as bool);
    } else if (type == (AudioCodecSetting).toString()) {
      return AudioCodecSetting(AudioCodec.fromJson(value));
    } else if (type == (UsePhoneRingtoneSetting).toString()) {
      return UsePhoneRingtoneSetting(value as bool);
    } else if (type == (UseVoipSetting).toString()) {
      return UseVoipSetting(value as bool);
    } else if (type == (ShowCallsInNativeRecentsSetting).toString()) {
      return ShowCallsInNativeRecentsSetting(value as bool);
    } else if (type == (AvailabilitySetting).toString()) {
      return AvailabilitySetting(
        Availability.fromJson(value as Map<String, dynamic>),
      );
    } else if (type == (ClientOutgoingNumbersSetting).toString()) {
      return ClientOutgoingNumbersSetting(
        ClientAvailableOutgoingNumbers.fromJson(value as Map<String, dynamic>),
      );
    } else if (type == (DndSetting).toString()) {
      return DndSetting(value as bool);
    } else if (type == (ShowClientCallsSetting).toString()) {
      return ShowClientCallsSetting(value as bool);
    } else if (type == (VoipgridPermissionsSetting).toString()) {
      return VoipgridPermissionsSetting(
        VoipgridPermissions.fromJson(value as Map<String, dynamic>),
      );
    }
    else {
      assert(false, 'Setting type does not exist: $type');
      return null;
    }
  }

  Setting<T> copyWith({T value});

  @override
  bool operator ==(Object? other) {
    return other is Setting<T> && other.value == value;
  }

  @override
  int get hashCode => runtimeType.hashCode + value.hashCode;
}

class RemoteLoggingSetting extends Setting<bool> {
  const RemoteLoggingSetting(bool value) : super(value);

  const RemoteLoggingSetting.preset() : this(false);

  @override
  RemoteLoggingSetting copyWith({bool? value}) =>
      RemoteLoggingSetting(value ?? this.value);
}

class ShowDialerConfirmPopupSetting extends Setting<bool> {
  const ShowDialerConfirmPopupSetting(bool value) : super(value);

  const ShowDialerConfirmPopupSetting.preset() : this(true);

  @override
  ShowDialerConfirmPopupSetting copyWith({bool? value}) =>
      ShowDialerConfirmPopupSetting(value ?? this.value);
}

class ShowSurveysSetting extends Setting<bool> {
  const ShowSurveysSetting(bool value) : super(value);

  const ShowSurveysSetting.preset() : this(true);

  @override
  ShowSurveysSetting copyWith({bool? value}) =>
      ShowSurveysSetting(value ?? this.value);
}

@Deprecated('Use `OutgoingNumberSetting` instead')
class BusinessNumberSetting extends Setting<String> {
  const BusinessNumberSetting(String value)
      : super(value, mutable: true, external: true);

  @override
  BusinessNumberSetting copyWith({String? value}) =>
      BusinessNumberSetting(value ?? this.value);

  bool get isSuppressed => value.isSuppressed;
}

class OutgoingNumberSetting extends Setting<String> {
  const OutgoingNumberSetting(String value)
      : super(value, mutable: true, external: true);

  @override
  OutgoingNumberSetting copyWith({String? value}) =>
      OutgoingNumberSetting(value ?? this.value);

  OutgoingNumberSetting.suppressed()
      : super('suppressed', mutable: true, external: true);

  bool get isSuppressed => value.isSuppressed;
}

class MobileNumberSetting extends Setting<String> {
  const MobileNumberSetting(String value)
      : super(value, mutable: true, external: true);

  @override
  MobileNumberSetting copyWith({String? value}) =>
      MobileNumberSetting(value ?? this.value);
}

class DndSetting extends Setting<bool> {
  const DndSetting(bool value) : super(value);

  const DndSetting.preset() : this(false);

  @override
  DndSetting copyWith({bool? value}) => DndSetting(value ?? this.value);
}

class UseVoipSetting extends Setting<bool> {
  const UseVoipSetting(bool value) : super(value);

  const UseVoipSetting.preset() : this(true);

  @override
  UseVoipSetting copyWith({bool? value}) => UseVoipSetting(value ?? this.value);
}

class ShowTroubleshootingSettingsSetting extends Setting<bool> {
  const ShowTroubleshootingSettingsSetting(bool value) : super(value);

  const ShowTroubleshootingSettingsSetting.preset() : this(false);

  @override
  ShowTroubleshootingSettingsSetting copyWith({bool? value}) =>
      ShowTroubleshootingSettingsSetting(value ?? this.value);
}

class UseEncryptionSetting extends Setting<bool> {
  const UseEncryptionSetting(bool value) : super(value);

  const UseEncryptionSetting.preset() : this(true);

  @override
  UseEncryptionSetting copyWith({bool? value}) =>
      UseEncryptionSetting(value ?? this.value);
}

class AudioCodecSetting extends Setting<AudioCodec> {
  const AudioCodecSetting(AudioCodec value) : super(value);

  const AudioCodecSetting.preset() : this(AudioCodec.opus);

  @override
  AudioCodecSetting copyWith({AudioCodec? value}) =>
      AudioCodecSetting(value ?? this.value);
}

class UsePhoneRingtoneSetting extends Setting<bool> {
  const UsePhoneRingtoneSetting(bool value) : super(value);

  const UsePhoneRingtoneSetting.preset() : this(false);

  @override
  UsePhoneRingtoneSetting copyWith({bool? value}) =>
      UsePhoneRingtoneSetting(value ?? this.value);
}

class ShowCallsInNativeRecentsSetting extends Setting<bool> {
  const ShowCallsInNativeRecentsSetting(bool value) : super(value);

  const ShowCallsInNativeRecentsSetting.preset() : this(true);

  @override
  ShowCallsInNativeRecentsSetting copyWith({bool? value}) =>
      ShowCallsInNativeRecentsSetting(value ?? this.value);
}

class AvailabilitySetting extends Setting<Availability?> {
  const AvailabilitySetting(Availability? value)
      : super(value, mutable: true, external: true);

  const AvailabilitySetting.preset() : this(null);

  @override
  AvailabilitySetting copyWith({Availability? value}) =>
      AvailabilitySetting(value ?? this.value);

  @override
  final bool shouldTrack = false;
}

class ShowClientCallsSetting extends Setting<bool> {
  const ShowClientCallsSetting(bool value) : super(value);

  const ShowClientCallsSetting.preset() : this(false);

  @override
  ShowClientCallsSetting copyWith({bool? value}) =>
      ShowClientCallsSetting(value ?? this.value);
}

class VoipgridPermissionsSetting extends Setting<VoipgridPermissions> {
  const VoipgridPermissionsSetting(VoipgridPermissions value)
      : super(value, mutable: true, external: true);

  const VoipgridPermissionsSetting.preset()
      : this(const VoipgridPermissions(hasClientCallsPermission: false));

  @override
  VoipgridPermissionsSetting copyWith({VoipgridPermissions? value}) =>
      VoipgridPermissionsSetting(value ?? this.value);
}

class ClientOutgoingNumbersSetting
    extends Setting<ClientAvailableOutgoingNumbers> {
  const ClientOutgoingNumbersSetting(ClientAvailableOutgoingNumbers value)
      : super(value, mutable: true, external: true);

  const ClientOutgoingNumbersSetting.preset()
      : this(
          const ClientAvailableOutgoingNumbers(
            numbers: [],
          ),
        );

  @override
  final bool isPii = true;

  @override
  ClientOutgoingNumbersSetting copyWith({
    ClientAvailableOutgoingNumbers? value,
  }) =>
      ClientOutgoingNumbersSetting(value ?? this.value);
}

extension SettingsByType on Iterable<Setting> {
  T get<T extends Setting>() => getOrNull<T>()!;

  T? getOrNull<T extends Setting>() {
    return firstOrNullWhere((setting) => setting is T) as T?;
  }
}

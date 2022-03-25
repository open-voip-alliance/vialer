// ignore_for_file: avoid_positional_boolean_parameters

import 'package:dartx/dartx.dart';
import 'package:meta/meta.dart';

import 'audio_codec.dart';
import 'availability.dart';

@immutable
abstract class Setting<T> {
  static const _typeKey = 'type';
  static const _valueKey = 'value';

  final T value;

  final bool mutable;

  /// Whether the setting is external, meaning: The setting has a source that's
  /// not our local storage (the portal, VoIP library, etc.)
  final bool external;

  const Setting(
    this.value, {
    this.mutable = true,
    this.external = false,
  });

  static const List<Setting> presets = [
    RemoteLoggingSetting.preset(),
    ShowDialerConfirmPopupSetting.preset(),
    ShowSurveyDialogSetting.preset(),
    UseVoipSetting.preset(),
    ShowTroubleshootingSettingsSetting.preset(),
    UseEncryptionSetting.preset(),
    AudioCodecSetting.preset(),
    UsePhoneRingtoneSetting.preset(),
    ShowCallsInNativeRecentsSetting.preset(),
    AvailabilitySetting.preset(),
    DndSetting.preset(),
  ];

  Map<String, dynamic> toJson() {
    return {
      _typeKey: runtimeType.toString(),
      _valueKey: value,
    };
  }

  static Setting fromJson(Map<String, dynamic> json) {
    final type = json[_typeKey];
    final value = json[_valueKey];

    assert(type != null);
    assert(value != null);

    if (type == (RemoteLoggingSetting).toString()) {
      return RemoteLoggingSetting(value as bool);
    } else if (type == (ShowDialerConfirmPopupSetting).toString()) {
      return ShowDialerConfirmPopupSetting(value as bool);
    } else if (type == (ShowSurveyDialogSetting).toString()) {
      return ShowSurveyDialogSetting(value as bool);
    } else if (type == (BusinessNumberSetting).toString()) {
      return BusinessNumberSetting(value as String);
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
    } else if (type == (DndSetting).toString()) {
      return DndSetting(value as bool);
    } else {
      throw UnsupportedError('Setting type does not exist: $type');
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

class ShowSurveyDialogSetting extends Setting<bool> {
  const ShowSurveyDialogSetting(bool value) : super(value);

  const ShowSurveyDialogSetting.preset() : this(true);

  @override
  ShowSurveyDialogSetting copyWith({bool? value}) =>
      ShowSurveyDialogSetting(value ?? this.value);
}

class BusinessNumberSetting extends Setting<String> {
  const BusinessNumberSetting(String value)
      : super(value, mutable: false, external: true);

  @override
  BusinessNumberSetting copyWith({String? value}) =>
      BusinessNumberSetting(value ?? this.value);
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
}

extension SettingsByType on Iterable<Setting> {
  T get<T extends Setting>() => getOrNull<T>()!;

  T? getOrNull<T extends Setting>() {
    return firstOrNullWhere((setting) => setting is T) as T?;
  }
}

// ignore_for_file: avoid_positional_boolean_parameters
import 'package:meta/meta.dart';
import 'package:dartx/dartx.dart';

import 'audio_codec.dart';

@immutable
abstract class Setting<T> {
  static const _typeKey = 'type';
  static const _valueKey = 'value';

  final T value;

  final bool mutable;

  /// Whether the setting is external, meaning: The setting has a source that's
  /// not our local storage (the portal, VoIP library, etc.)
  final bool external;

  Setting(
    this.value, {
    this.mutable = true,
    this.external = false,
  });

  static final List<Setting> presets = [
    RemoteLoggingSetting.preset(),
    ShowDialerConfirmPopupSetting.preset(),
    ShowSurveyDialogSetting.preset(),
    UseVoipSetting.preset(),
    ShowTroubleshootingSettingsSetting.preset(),
    UseEncryptionSetting.preset(),
    AudioCodecSetting.preset(),
    UsePhoneRingtoneSetting.preset(),
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
    } else if (type == (PhoneNumberSetting).toString()) {
      return PhoneNumberSetting(value as String);
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
    } else {
      throw UnsupportedError('Setting type does not exist: $type');
    }
  }

  Setting<T> copyWith({T value});

  @override
  bool operator ==(other) {
    return other.runtimeType == runtimeType && other.value == value;
  }

  @override
  int get hashCode => runtimeType.hashCode + value.hashCode;
}

class RemoteLoggingSetting extends Setting<bool> {
  RemoteLoggingSetting(bool value) : super(value);

  RemoteLoggingSetting.preset() : this(false);

  @override
  RemoteLoggingSetting copyWith({bool value}) => RemoteLoggingSetting(value);
}

class ShowDialerConfirmPopupSetting extends Setting<bool> {
  ShowDialerConfirmPopupSetting(bool value) : super(value);

  ShowDialerConfirmPopupSetting.preset() : this(true);

  @override
  ShowDialerConfirmPopupSetting copyWith({bool value}) =>
      ShowDialerConfirmPopupSetting(value);
}

class ShowSurveyDialogSetting extends Setting<bool> {
  ShowSurveyDialogSetting(bool value) : super(value);

  ShowSurveyDialogSetting.preset() : this(true);

  @override
  ShowSurveyDialogSetting copyWith({bool value}) =>
      ShowSurveyDialogSetting(value);
}

class PhoneNumberSetting extends Setting<String> {
  PhoneNumberSetting(String value)
      : super(value, mutable: false, external: true);

  @override
  PhoneNumberSetting copyWith({String value}) => PhoneNumberSetting(value);
}

class UseVoipSetting extends Setting<bool> {
  UseVoipSetting(bool value) : super(value);

  @override
  UseVoipSetting copyWith({bool value}) => UseVoipSetting(value);

  UseVoipSetting.preset() : this(true);
}

class ShowTroubleshootingSettingsSetting extends Setting<bool> {
  ShowTroubleshootingSettingsSetting(bool value) : super(value);

  ShowTroubleshootingSettingsSetting.preset() : this(false);

  @override
  ShowTroubleshootingSettingsSetting copyWith({bool value}) =>
      ShowTroubleshootingSettingsSetting(value);
}

class UseEncryptionSetting extends Setting<bool> {
  UseEncryptionSetting(bool value) : super(value);

  UseEncryptionSetting.preset() : this(true);

  @override
  UseEncryptionSetting copyWith({bool value}) => UseEncryptionSetting(value);
}

class AudioCodecSetting extends Setting<AudioCodec> {
  AudioCodecSetting(AudioCodec value) : super(value);

  AudioCodecSetting.preset() : this(AudioCodec.opus);

  @override
  AudioCodecSetting copyWith({AudioCodec value}) => AudioCodecSetting(value);
}

class UsePhoneRingtoneSetting extends Setting<bool> {
  UsePhoneRingtoneSetting(bool value) : super(value);

  UsePhoneRingtoneSetting.preset() : this(false);

  @override
  UsePhoneRingtoneSetting copyWith({bool value}) =>
      UsePhoneRingtoneSetting(value);
}

extension SettingsByType on Iterable<Setting> {
  T get<T extends Setting>() {
    return firstOrNullWhere((setting) => setting is T) as T;
  }
}

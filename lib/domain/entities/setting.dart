import 'package:meta/meta.dart';
import 'package:dartx/dartx.dart';

@immutable
abstract class Setting<T> {
  static const _typeKey = 'type';
  static const _valueKey = 'value';

  final T value;
  final bool mutable;

  /// Whether the setting is external, meaning: The setting has a source that's
  /// not our local storage (the portal, VoIP library, etc.)
  final bool external;

  Setting(this.value, {this.mutable = true, this.external = false});

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
    } else {
      throw UnsupportedError('Setting type does not exist');
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
  // ignore: avoid_positional_boolean_parameters
  RemoteLoggingSetting(bool value) : super(value);

  @override
  RemoteLoggingSetting copyWith({bool value}) => RemoteLoggingSetting(value);
}

class ShowDialerConfirmPopupSetting extends Setting<bool> {
  // ignore: avoid_positional_boolean_parameters
  ShowDialerConfirmPopupSetting(bool value) : super(value);

  @override
  ShowDialerConfirmPopupSetting copyWith({bool value}) =>
      ShowDialerConfirmPopupSetting(value);
}

class ShowSurveyDialogSetting extends Setting<bool> {
  // ignore: avoid_positional_boolean_parameters
  ShowSurveyDialogSetting(bool value) : super(value);

  @override
  ShowSurveyDialogSetting copyWith({bool value}) =>
      ShowSurveyDialogSetting(value);
}

class PhoneNumberSetting extends Setting<String> {
  PhoneNumberSetting(String value)
      : super(value, mutable: false, external: true);

  @override
  Setting<String> copyWith({String value}) => PhoneNumberSetting(value);
}

extension SettingsByType on List<Setting> {
  T get<T extends Setting>() {
    return firstOrNullWhere((setting) => setting is T) as T;
  }
}

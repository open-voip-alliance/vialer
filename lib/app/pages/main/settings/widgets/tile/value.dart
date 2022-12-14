import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/user/settings/settings.dart';
import '../../../widgets/stylized_switch.dart';
import '../../cubit.dart';

typedef ValueChangedWithContext<T extends Object> = void Function(
  BuildContext,
  SettingKey<T>,
  T,
);

Future<void> defaultOnChanged<T extends Object>(
  BuildContext context,
  SettingKey<T> key,
  T value,
) async {
  await context.read<SettingsCubit>().changeSetting(key, value);
}

class BoolSettingValue extends StatelessWidget {
  final Settings settings;
  final SettingKey<bool> settingKey;
  final ValueChangedWithContext<bool>? onChanged;

  const BoolSettingValue(
    this.settings,
    this.settingKey, {
    this.onChanged = defaultOnChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StylizedSwitch(
      value: settings.getOrNull(settingKey) ?? false,
      onChanged: onChanged != null
          ? (value) => onChanged!(context, settingKey, value)
          : null,
    );
  }
}

class StringValue extends StatelessWidget {
  final String value;
  final bool bold;

  const StringValue(
    this.value, {
    bool? bold,
    Key? key,
  })  : bold = bold ?? true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 16,
        fontWeight: bold ? FontWeight.bold : null,
      ),
    );
  }
}

typedef GetStringValue<T> = String Function(T);

class StringSettingValue<T extends Object> extends StatelessWidget {
  final Settings settings;
  final SettingKey<T> settingKey;

  /// If [T] is not [String], use this function to retrieve the
  /// desired string value of [T].
  final GetStringValue<T> value;
  final bool? bold;

  StringSettingValue(
    this.settings,
    this.settingKey, {
    GetStringValue<T>? value,
    this.bold,
    super.key,
  })  : value = value ?? ((obj) => obj.toString()),
        assert(T == String || value != null);

  @override
  Widget build(BuildContext context) {
    final settingValue = settings.getOrNull(settingKey);
    return StringValue(
      settingValue != null ? value(settingValue) : '',
      bold: bold,
    );
  }
}

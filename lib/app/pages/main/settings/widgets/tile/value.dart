import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/user/settings/settings.dart';
import '../../../../../resources/localizations.dart';
import '../../../widgets/stylized_switch.dart';
import '../../cubit.dart';

typedef ValueChangedWithContext<T extends Object> = void Function(
  BuildContext,
  SettingKey<T>,
  T,
);

/// If the setting cannot be changed, a dialog is shown.
Future<void> runIfSettingCanBeChanged(
  BuildContext context,
  Iterable<SettingKey> keys,
  FutureOr<void> Function() block,
) async {
  final settings = context.read<SettingsCubit>();

  // Check that we can change all the keys in the request.
  final canChangeRemoteSetting = await Future.wait(
    keys.map((key) async => settings.canChangeRemoteSetting(key)),
  ).then(
    (value) => value.all((canChange) => canChange),
  );

  if (canChangeRemoteSetting) {
    await block.call();
  } else {
    // Linter is wrong here.
    // ignore: use_build_context_synchronously
    if (!context.mounted) return;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(context.msg.main.settings.noConnectionDialog.title),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.msg.generic.button.close),
              )
            ],
            content: Text(context.msg.main.settings.noConnectionDialog.message),
          );
        },
      ),
    );
  }
}

Future<void> defaultOnSettingChanged<T extends Object>(
  BuildContext context,
  SettingKey<T> key,
  T value,
) =>
    runIfSettingCanBeChanged(
      context,
      [key],
      () => context.read<SettingsCubit>().changeSetting(key, value),
    );

Future<void> defaultOnSettingsChanged<T extends Object>(
  BuildContext context,
  Map<SettingKey, Object> settings,
) =>
    runIfSettingCanBeChanged(
      context,
      settings.keys,
      () => context.read<SettingsCubit>().changeSettings(settings),
    );

class BoolSettingValue extends StatelessWidget {
  const BoolSettingValue(
    this.settings,
    this.settingKey, {
    this.onChanged = defaultOnSettingChanged,
    super.key,
  });

  final Settings settings;
  final SettingKey<bool> settingKey;
  final ValueChangedWithContext<bool>? onChanged;

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
  const StringValue(
    this.value, {
    bool? bold,
    super.key,
  }) : bold = bold ?? true;
  final String value;
  final bool bold;

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
  StringSettingValue(
    this.settings,
    this.settingKey, {
    GetStringValue<T>? value,
    this.bold,
    super.key,
  })  : value = value ?? ((obj) => obj.toString()),
        assert(
          T == String || value != null,
          'settingKey must be SettingKey<String> or value must be set',
        );
  final Settings settings;
  final SettingKey<T> settingKey;

  /// If [T] is not [String], use this function to retrieve the
  /// desired string value of [T].
  final GetStringValue<T> value;
  final bool? bold;

  @override
  Widget build(BuildContext context) {
    final settingValue = settings.getOrNull(settingKey);
    return StringValue(
      settingValue != null ? value(settingValue) : '',
      bold: bold,
    );
  }
}

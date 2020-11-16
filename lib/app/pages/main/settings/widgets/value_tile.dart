import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/entities/setting.dart';
import '../../../../entities/setting_info.dart';
import '../../../../resources/theme.dart';
import 'audio_codec_value.dart';
import 'tile.dart';

class SettingValueTile extends StatelessWidget {
  final SettingInfo info;
  final ValueChanged<Setting> onChanged;

  const SettingValueTile(
    this.info, {
    Key key,
    @required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final setting = info.item;

    final onChanged = setting.mutable ? this.onChanged : null;

    Widget value;
    if (setting is Setting<bool>) {
      value = _BoolSettingValue(setting, onChanged);
    } else if (setting is Setting<String>) {
      value = _StringSettingValue(setting, onChanged);
    } else if (setting is AudioCodecSetting) {
      value = AudioCodecSettingValue(setting, onChanged);
    } else {
      throw UnsupportedError(
        'Vialer error: Unsupported operation: Unknown setting generic type. '
        'Please add a widget that can handle this generic type.',
      );
    }

    return _SettingValueTile(
      info,
      value: value,
      valueFillWidth: setting is AudioCodecSetting,
    );
  }
}

class _SettingValueTile extends StatelessWidget {
  final SettingInfo info;

  /// The widget that presents the [setting]s value.
  final Widget value;

  final bool valueFillWidth;

  const _SettingValueTile(
    this.info, {
    this.value,
    this.valueFillWidth = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      label: Text(info.name),
      description: info.description != null ? Text(info.description) : null,
      childFillWidth: valueFillWidth,
      child: value,
    );
  }
}

class _BoolSettingValue extends StatelessWidget {
  final Setting<bool> setting;
  final ValueChanged<Setting<bool>> onChanged;

  const _BoolSettingValue(
    this.setting,
    this.onChanged, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Switch(
      value: setting.value,
      onChanged: (value) => onChanged(
        setting.copyWith(value: value),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Switch({Key key, this.value, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (context.isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      );
    } else {
      return Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      );
    }
  }
}

class _StringSettingValue extends StatelessWidget {
  final Setting<String> setting;
  final ValueChanged<Setting<String>> onChanged;

  const _StringSettingValue(
    this.setting,
    this.onChanged, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      setting.value,
      style: TextStyle(
        fontSize: 16,
        fontWeight: !context.isIOS ? FontWeight.bold : null,
      ),
    );
  }
}

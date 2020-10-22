import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../resources/theme.dart';

import '../../../../entities/category.dart';

import '../../../../../domain/entities/setting.dart';

import '../../../../mappers/setting.dart';

import '../../../../util/conditional_capitalization.dart';

class SettingTile<S extends Setting> extends StatelessWidget {
  final S setting;
  final ValueChanged<S> onChanged;

  const SettingTile(
    this.setting, {
    Key key,
    @required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Needed for auto cast.
    final setting = this.setting;

    // The cast in onChanged is safe, because the Setting returned by
    // copyWith will always be the same type.
    final onChanged =
        setting.mutable ? (setting) => this.onChanged(setting as S) : null;

    Widget value;
    if (setting is Setting<bool>) {
      value = _BoolSettingValue(setting, onChanged);
    } else if (setting is Setting<String>) {
      value = _StringSettingValue(setting, onChanged);
    } else {
      throw UnsupportedError(
        'Vialer error: Unsupported operation: Unknown setting generic type. '
        'Please add a widget that can handle this generic type.',
      );
    }

    return _SettingTile(
      setting,
      value: value,
    );
  }
}

class SettingTileCategory extends StatelessWidget {
  final Category category;
  final List<Widget> children;
  final EdgeInsets padding;

  const SettingTileCategory({
    Key key,
    this.category,
    this.padding = EdgeInsets.zero,
    this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = category.toInfo(context);

    const dividerHeight = 1.0;
    // Default divider height halved, minus 1 for the thickness (actual height
    // in our case).
    const dividerPadding = 16 / 2 - dividerHeight;

    return Column(
      children: <Widget>[
        Container(
          color: category == Category.accountInfo
              ? context.brandTheme.settingsBackgroundHighlight
              : null,
          child: Padding(
            padding: padding.copyWith(
              top: padding.top + dividerPadding,
              bottom: padding.bottom + dividerPadding,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      info.icon,
                      color: context.brandTheme.grey1,
                      size: !context.isIOS ? 16 : null,
                    ),
                    SizedBox(width: 8),
                    Text(
                      info.title.toUpperCaseIfAndroid(context),
                      style: TextStyle(
                        color: !context.isIOS
                            ? Theme.of(context).primaryColor
                            : null,
                        fontSize: context.isIOS ? 18 : 12,
                        fontWeight: context.isIOS ? null : FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (context.isIOS) SizedBox(height: 16),
                ...children,
              ],
            ),
          ),
        ),
        // We don't use the default height so the highlight background color
        // ends exactly at the divider.
        if (!context.isIOS) const Divider(height: dividerHeight),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final Setting setting;

  /// The widget that presents the [setting]s value.
  final Widget value;

  const _SettingTile(
    this.setting, {
    this.value,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = setting.toInfo(context);

    return Column(
      children: <Widget>[
        Container(
          constraints: const BoxConstraints(
            minWidth: double.infinity,
            minHeight: 48,
          ),
          decoration: context.isIOS
              ? BoxDecoration(
                  border: Border.all(
                    color: context.brandTheme.grey2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          padding: EdgeInsets.only(
            top: context.isIOS ? 8 : 0,
            left: context.isIOS ? 16 : 24,
            right: 8,
            bottom: context.isIOS ? 8 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                info.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: !context.isIOS ? FontWeight.bold : null,
                ),
              ),
              value,
            ],
          ),
        ),
        if (info.description != null) ...[
          Padding(
            padding: EdgeInsets.only(
              left: context.isIOS ? 8 : 24,
              right: 8,
              top: context.isIOS ? 8 : 0,
              bottom: 16,
            ),
            child: Text(
              info.description,
              style: TextStyle(
                color: context.brandTheme.grey4,
              ),
            ),
          ),
        ],
      ],
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

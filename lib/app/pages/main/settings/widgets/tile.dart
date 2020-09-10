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
    // Needed for auto cast
    final setting = this.setting;

    if (setting is Setting<bool>) {
      return _BoolSettingTile<Setting<bool>>(
        setting,
        (setting) => onChanged(setting as S),
      );
    } else {
      throw UnsupportedError('Unknown setting generic type');
    }
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

    return Column(
      children: <Widget>[
        Padding(
          padding: padding,
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
        if (!context.isIOS) Divider()
      ],
    );
  }
}

class _BoolSettingTile<S extends Setting<bool>> extends StatelessWidget {
  final S setting;
  final ValueChanged<S> onChanged;

  const _BoolSettingTile(
    this.setting,
    this.onChanged, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = setting.toInfo(context);

    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
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
              _Switch(
                value: setting.value,
                onChanged: (value) => onChanged(
                  setting.copyWith(value: value) as S,
                ),
              )
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

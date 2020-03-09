import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../resources/theme.dart';

import '../../../../entities/category.dart';

import '../../../../../domain/entities/setting.dart';

import '../../../../mappers/setting.dart';

class SettingTile extends StatelessWidget {
  final Setting setting;
  final ValueChanged<bool> onChanged;

  const SettingTile(
    this.setting, {
    Key key,
    @required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (setting is Setting<bool>) {
      return _BoolSettingTile(setting, onChanged);
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

    final title = !context.isIOS ? info.title.toUpperCase() : info.title;

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
                    color: VialerColors.grey1,
                    size: !context.isIOS ? 16 : null,
                  ),
                  SizedBox(width: 8),
                  Text(
                    title,
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

class _BoolSettingTile extends StatefulWidget {
  final Setting<bool> setting;
  final ValueChanged<bool> onChanged;

  const _BoolSettingTile(
    this.setting,
    this.onChanged, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BoolSettingTileState();
}

class _BoolSettingTileState extends State<_BoolSettingTile> {
  _BoolSettingTileState();

  @override
  Widget build(BuildContext context) {
    final info = widget.setting.toInfo(context);

    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          decoration: context.isIOS
              ? BoxDecoration(
                  border: Border.all(
                    color: VialerColors.grey2,
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
                value: widget.setting.value,
                onChanged: widget.onChanged,
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
                color: VialerColors.grey4,
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

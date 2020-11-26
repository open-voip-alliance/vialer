import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/audio_codec.dart';
import '../../../../../domain/entities/brand.dart';
import '../../../../../domain/entities/setting.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../cubit.dart';

class SettingTile extends StatelessWidget {
  final Widget label;
  final Widget description;

  /// The widget that presents the [setting]s value.
  final Widget child;

  /// If this is true, the [child] will be the maximum width and on the
  /// next line. Defaults to false.
  final bool childFillWidth;

  const SettingTile({
    Key key,
    @required this.label,
    this.description,
    this.child,
    this.childFillWidth = false,
  }) : super(key: key);

  static Widget phoneNumber(PhoneNumberSetting setting) {
    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(
            context.msg.main.settings.list.accountInfo.phoneNumber.title,
          ),
          description: Text(
            context.msg.main.settings.list.accountInfo.phoneNumber.description,
          ),
          child: _StringSettingValue(setting),
        );
      },
    );
  }

  static Widget usePhoneRingtone(UsePhoneRingtoneSetting setting) {
    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(
            context.msg.main.settings.list.audio.usePhoneRingtone.title,
          ),
          description: Text(
            context.msg.main.settings.list.audio.usePhoneRingtone.description(
              Provider.of<Brand>(context, listen: false).appName,
            ),
          ),
          child: _BoolSettingValue(setting),
        );
      },
    );
  }

  static Widget useVoip(UseVoipSetting setting) {
    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(context.msg.main.settings.list.calling.useVoip.title),
          description: Text(
            context.msg.main.settings.list.calling.useVoip.description,
          ),
          child: _BoolSettingValue(setting),
        );
      },
    );
  }

  static Widget remoteLogging(RemoteLoggingSetting setting) {
    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(context.msg.main.settings.list.debug.remoteLogging.title),
          description: Text(
            context.msg.main.settings.list.debug.remoteLogging.description,
          ),
          child: _BoolSettingValue(setting),
        );
      },
    );
  }

  static Widget useEncryption(UseEncryptionSetting setting) {
    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(
            context.msg.main.settings.list.advancedSettings.troubleshooting.list
                .calling.useEncryption,
          ),
          child: _BoolSettingValue(setting),
        );
      },
    );
  }

  static Widget audioCodec(AudioCodecSetting setting) {
    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(
            context.msg.main.settings.list.advancedSettings.troubleshooting.list
                .calling.useEncryption,
          ),
          childFillWidth: true,
          // Might be generalized into a _MultipleChoiceSettingValue
          // widget later on.
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButton<AudioCodec>(
              value: setting.value,
              isExpanded: true,
              items: [
                // TODO: Get values from PIL.
                DropdownMenuItem(
                  value: AudioCodec.opus,
                  child: Text(AudioCodec.opus.value.toUpperCase()),
                ),
              ],
              onChanged: (codec) => defaultOnChanged(
                context,
                setting.copyWith(value: codec),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: double.infinity,
                  minHeight: 48,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: !context.isIOS ? FontWeight.bold : null,
                      ),
                      child: Expanded(
                        child: label,
                      ),
                    ),
                    if (!childFillWidth) child,
                  ],
                ),
              ),
              if (childFillWidth) child,
            ],
          ),
        ),
        if (description != null)
          Padding(
            padding: EdgeInsets.only(
              left: context.isIOS ? 8 : 24,
              right: 8,
              top: context.isIOS ? 8 : 0,
              bottom: 16,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: context.brandTheme.grey4,
              ),
              child: description,
            ),
          ),
      ],
    );
  }
}

typedef ValueChangedWithContext<T> = void Function(BuildContext, T);

void defaultOnChanged<T>(BuildContext context, Setting<T> setting) {
  context.read<SettingsCubit>().changeSetting(setting);
}

class _BoolSettingValue extends StatelessWidget {
  final Setting<bool> setting;
  final ValueChangedWithContext<Setting<bool>> onChanged;

  const _BoolSettingValue(
    this.setting, {
    this.onChanged = defaultOnChanged,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Switch(
      value: setting.value,
      onChanged: (value) => onChanged(
        context,
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

  const _StringSettingValue(
    this.setting, {
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

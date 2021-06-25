import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/audio_codec.dart';
import '../../../../../domain/entities/brand.dart';
import '../../../../../domain/entities/destination.dart';
import '../../../../../domain/entities/fixed_destination.dart';
import '../../../../../domain/entities/phone_account.dart';
import '../../../../../domain/entities/setting.dart';
import '../../../../../domain/entities/web_page.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/brand.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../web_view/page.dart';
import '../cubit.dart';

class SettingTile extends StatelessWidget {
  final Widget label;
  final Widget? description;

  /// The widget that presents the [setting]s value.
  final Widget child;

  /// If this is true, the [child] will be the maximum width and on the
  /// next line. Defaults to false.
  final bool childFillWidth;

  /// If this is true, the widget will be centered.
  final bool center;

  const SettingTile({
    Key? key,
    required this.label,
    this.description,
    required this.child,
    this.childFillWidth = false,
    this.center = false,
  }) : super(key: key);

  static Widget dnd(DndSetting setting) {
    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(
            context.msg.main.settings.list.dnd.dnd.title,
          ),
          description: Text(
            context.msg.main.settings.list.dnd.dnd.description(
              Provider.of<Brand>(context, listen: false).appName,
            ),
          ),
          child: _BoolSettingValue(setting),
        );
      },
    );
  }

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
          child: _BoolSettingValue(
            setting,
            onChanged: (context, setting) {
              // Show a popup, asking if the user wants to send their locally
              // saved logs to the remote.
              if (setting.value) {
                showDialog(
                  context: context,
                  builder: (_) => _RemoteLoggingSendLogsDialog(
                    cubit: context.read<SettingsCubit>(),
                  ),
                );
              }
              defaultOnChanged(context, setting);
            },
          ),
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
          child: _MultipleChoiceSettingValue<AudioCodec>(
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
        );
      },
    );
  }

  static Widget availability(AvailabilitySetting setting) {
    final availability = setting.value;

    return Builder(
      builder: (context) {
        void openAddAvailabilityWebView() {
          WidgetsBinding.instance!.addPostFrameCallback((_) async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebViewPage(
                  WebPage.addDestination,
                ),
              ),
            );

            context.read<SettingsCubit>().refreshAvailability();
          });
        }

        return SettingTile(
          label: Text(
            context.msg.main.settings.list.calling.availability.title,
          ),
          description: Text(
            context.msg.main.settings.list.calling.availability.description,
          ),
          childFillWidth: true,
          child: _MultipleChoiceSettingValue<Destination?>(
            value: availability?.activeDestination,
            items: [
              ...availability?.destinations.map(
                    (destination) => DropdownMenuItem<Destination>(
                      child: Text(destination.dropdownValue(context)),
                      value: destination,
                    ),
                  ) ??
                  [],
              DropdownMenuItem<Destination>(
                child: Text(
                  context.msg.main.settings.list.calling.addAvailability,
                ),
                value: null,
                onTap: openAddAvailabilityWebView,
              ),
            ],
            onChanged: (destination) => destination != null
                ? defaultOnChanged(
                    context,
                    setting.copyWith(
                      value: availability?.copyWithSelectedDestination(
                        destination: destination,
                      ),
                    ),
                  )
                : () {},
            isExpanded: true,
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
                    color: context.brand.theme.grey2,
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
                  mainAxisAlignment: center
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: !context.isIOS ? FontWeight.bold : null,
                      ),
                      child: center
                          ? label
                          : Expanded(
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
                color: context.brand.theme.grey4,
              ),
              child: description!,
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
    Key? key,
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

  const _Switch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

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
    Key? key,
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

class _MultipleChoiceSettingValue<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final bool isExpanded;
  final ValueChanged<T> onChanged;

  const _MultipleChoiceSettingValue({
    Key? key,
    required this.value,
    required this.items,
    this.isExpanded = false,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: DropdownButton<T>(
        value: value,
        items: items,
        isExpanded: isExpanded,
        onChanged: (value) => onChanged(value!),
      ),
    );
  }
}

class _RemoteLoggingSendLogsDialog extends StatelessWidget {
  final SettingsCubit cubit;

  const _RemoteLoggingSendLogsDialog({
    Key? key,
    required this.cubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = Text(
      context
          .msg.main.settings.list.debug.remoteLogging.sendToRemoteDialog.title,
    );
    final content = Text(
      context.msg.main.settings.list.debug.remoteLogging.sendToRemoteDialog
          .description,
    );

    final deny = Text(
      context.msg.generic.button.noThanks.toUpperCaseIfAndroid(context),
    );
    final confirm = Text(
      context
          .msg.main.settings.list.debug.remoteLogging.sendToRemoteDialog.confirm
          .toUpperCaseIfAndroid(context),
    );

    void onDenyPressed() => Navigator.pop(context);
    void onConfirmPressed() {
      cubit.sendSavedLogsToRemote();
      Navigator.pop(context);
    }

    if (context.isAndroid) {
      return AlertDialog(
        title: title,
        content: content,
        actions: [
          TextButton(
            onPressed: onDenyPressed,
            child: deny,
          ),
          TextButton(
            onPressed: onConfirmPressed,
            child: confirm,
          ),
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: title,
        content: content,
        actions: [
          CupertinoDialogAction(
            onPressed: onDenyPressed,
            child: deny,
          ),
          CupertinoDialogAction(
            onPressed: onConfirmPressed,
            child: confirm,
          ),
        ],
      );
    }
  }
}

extension DestinationDescription on Destination {
  String dropdownValue(BuildContext context) {
    final destination = this;

    if (destination == FixedDestination.notAvailable) {
      return context.msg.main.settings.list.calling.notAvailable;
    } else {
      if (destination is FixedDestination) {
        if (destination.phoneNumber == null) {
          return '${destination.description}';
        }

        return '${destination.phoneNumber} / ${destination.description}';
      } else {
        return '${(destination as PhoneAccount).internalNumber} / '
            '${destination.description}';
      }
    }
  }
}

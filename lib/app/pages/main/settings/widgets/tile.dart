import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/audio_codec.dart';
import '../../../../../domain/entities/availability.dart';
import '../../../../../domain/entities/destination.dart';
import '../../../../../domain/entities/fixed_destination.dart';
import '../../../../../domain/entities/phone_account.dart';
import '../../../../../domain/entities/setting.dart';
import '../../../../../domain/entities/system_user.dart';
import '../../../../../domain/entities/web_page.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../onboarding/widgets/stylized_text_field.dart';
import '../../../web_view/page.dart';
import '../cubit.dart';
import 'availability_tile.dart';

class SettingTile extends StatelessWidget {
  final Widget? label;
  final Widget? description;

  /// The widget that presents the [setting]s value.
  final Widget child;

  /// If this is true, the [child] will be the maximum width and on the
  /// next line. Defaults to false.
  final bool childFillWidth;

  /// If this is true, the widget will be centered.
  final bool center;

  final EdgeInsetsGeometry? padding;

  /// Specify if a border should be shown, if null, platform defaults
  /// will be used.
  final bool? bordered;

  SettingTile({
    Key? key,
    this.label,
    this.description,
    required this.child,
    this.childFillWidth = false,
    this.center = false,
    EdgeInsetsGeometry? padding,
    this.bordered,
  })  : padding = padding ??
            EdgeInsets.only(
              top: Platform.isIOS ? 8 : 0,
              left: Platform.isIOS ? 16 : 24,
              right: 8,
              bottom: Platform.isIOS ? 8 : 0,
            ),
        super(key: key);

  static Widget dnd(
    DndSetting setting, {
    required UserAvailabilityType userAvailabilityType,
  }) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ).copyWith(
            top: 0,
          ),
          child: Row(
            children: [
              Expanded(
                child: _DndToggle(
                  setting: setting,
                  userAvailabilityType: userAvailabilityType,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget username(SystemUser systemUser) {
    return Builder(builder: (context) {
      return _userInformation(
        description: Text(
          context.msg.main.settings.list.accountInfo.username.description,
        ),
        child: _StringValue(systemUser.email),
      );
    });
  }

  static Widget associatedNumber(BusinessNumberSetting businessNumberSetting) {
    return Builder(builder: (context) {
      return _userInformation(
        description: Text(
          context.msg.main.settings.list.accountInfo.businessNumber.description,
        ),
        child: _StringSettingValue(businessNumberSetting),
      );
    });
  }

  static Widget mobileNumber({
    required MobileNumberSetting setting,
    required bool isVoipAllowed,
  }) {
    return Builder(
      builder: (context) {
        return SettingTile(
          description: isVoipAllowed
              ? Text(
                  context.msg.main.settings.list.accountInfo.mobileNumber
                      .description.voip,
                )
              : Text(
                  context.msg.main.settings.list.accountInfo.mobileNumber
                      .description.noVoip,
                ),
          childFillWidth: isVoipAllowed,
          child: isVoipAllowed
              ? _StringEditSettingValue(setting)
              : _StringSettingValue(setting),
        );
      },
    );
  }

  /// Build a default "user information" style field including a value
  /// with a description below it.
  static Widget _userInformation({
    required Widget description,
    required Widget child,
  }) {
    return Builder(
      builder: (context) {
        return SettingTile(
          childFillWidth: true,
          description: description,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: context.isIOS ? 8 : 4,
              top: context.isIOS ? 8 : 10,
            ),
            child: child,
          ),
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
              context.brand.appName,
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

  static Widget showCallsInNativeRecents(
    ShowCallsInNativeRecentsSetting setting,
  ) {
    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(
            context
                .msg.main.settings.list.calling.showCallsInNativeRecents.title,
          ),
          description: Text(
            context.msg.main.settings.list.calling.showCallsInNativeRecents
                .description(
              context.brand.appName,
            ),
          ),
          child: _BoolSettingValue(setting),
        );
      },
    );
  }

  static Widget ignoreBatteryOptimizations({
    required bool hasIgnoreBatteryOptimizationsPermission,
    required Function(bool) onChanged,
  }) {
    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(
            context.msg.main.settings.list.calling.ignoreBatteryOptimizations
                .title,
          ),
          description: Text(
            context.msg.main.settings.list.calling.ignoreBatteryOptimizations
                .description,
          ),
          child: _Switch(
            value: hasIgnoreBatteryOptimizationsPermission,
            // It is not possible to disable battery optimization via the app
            // so if we have the permission, this should just be disabled.
            onChanged:
                !hasIgnoreBatteryOptimizationsPermission ? onChanged : null,
          ),
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

  static Widget availability(
    AvailabilitySetting setting, {
    required SystemUser systemUser,
  }) {
    final availability = setting.value!;

    return Builder(
      builder: (context) {
        void openAddAvailabilityWebView() {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: AvailabilityTile(
            availability: availability,
            userAvailabilityType: systemUser.availabilityType(availability),
            user: systemUser,
            child: _MultipleChoiceSettingValue<Destination?>(
              value: availability.activeDestination,
              items: [
                ...availability.destinations.map(
                  (destination) => DropdownMenuItem<Destination>(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(destination.dropdownValue(context)),
                    ),
                    value: destination,
                  ),
                ),
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
                        value: availability.copyWithSelectedDestination(
                          destination: destination,
                        ),
                      ),
                    )
                  : () {},
              isExpanded: true,
            ),
          ),
        );
      },
    );
  }

  bool _shouldRenderBorder(BuildContext context) =>
      bordered != null ? bordered! : context.isIOS;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: _shouldRenderBorder(context)
              ? BoxDecoration(
                  border: Border.all(
                    color: context.brand.theme.colors.grey2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (label != null)
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
                            ? label!
                            : Expanded(
                                child: label!,
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
                color: context.brand.theme.colors.grey4,
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
  final ValueChanged<bool>? onChanged;

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

class _StringValue extends StatelessWidget {
  final String value;

  const _StringValue(
    this.value, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 16,
        fontWeight: !context.isIOS ? FontWeight.bold : null,
      ),
    );
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
    return _StringValue(
      setting.value,
    );
  }
}

class _StringEditSettingValue extends StatefulWidget {
  final Setting<String> setting;
  final ValueChangedWithContext<Setting<String>> onChanged;

  const _StringEditSettingValue(
    this.setting, {
    Key? key,
    // ignore: unused_element
    this.onChanged = defaultOnChanged,
  }) : super(key: key);

  @override
  _StringEditSettingValueState createState() => _StringEditSettingValueState();
}

class _StringEditSettingValueState extends State<_StringEditSettingValue> {
  final _textEditingController = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();

    _textEditingController.value = TextEditingValue(
      text: widget.setting.value,
      selection: TextSelection.collapsed(offset: widget.setting.value.length),
    );
  }

  void _onPressed(BuildContext context) {
    widget.onChanged(
      context,
      widget.setting.copyWith(value: _textEditingController.text),
    );
    _toggleEditing();
  }

  void _toggleEditing() {
    setState(() {
      _editing = !_editing;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return StylizedTextField(
        controller: _textEditingController,
        keyboardType: TextInputType.phone,
        autoCorrect: false,
        suffix: IconButton(
          onPressed: () => _onPressed(context),
          icon: const Icon(VialerSans.check),
        ),
        elevation: 0,
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            widget.setting.value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          IconButton(
            onPressed: _toggleEditing,
            icon: const Icon(VialerSans.edit),
          ),
        ],
      );
    }
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
      child: InputDecorator(
        decoration: InputDecoration(
          border:
              context.isAndroid ? const OutlineInputBorder() : InputBorder.none,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items,
            isExpanded: isExpanded,
            onChanged: (value) => onChanged(value!),
            isDense: true,
          ),
        ),
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
            style: TextButton.styleFrom(
              primary: context.brand.theme.colors.primary,
            ),
            onPressed: onDenyPressed,
            child: deny,
          ),
          TextButton(
            style: TextButton.styleFrom(
              primary: context.brand.theme.colors.primary,
            ),
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
        return '${(destination as PhoneAccount).internalNumber} /'
            ' ${destination.description}';
      }
    }
  }
}

extension AvailabilityType on SystemUser {
  UserAvailabilityType availabilityType(Availability availability) {
    final selectedDestination = availability.selectedDestinationInfo ?? null;

    if (selectedDestination == null ||
        (selectedDestination.phoneAccountId == null &&
            selectedDestination.fixedDestinationId == null)) {
      return UserAvailabilityType.notAvailable;
    }

    if (selectedDestination.phoneAccountId.toString() == appAccountId) {
      return UserAvailabilityType.available;
    }

    return UserAvailabilityType.elsewhere;
  }
}

/// Responsible for rendering the dnd toggle but also the current state of the
/// user's availability by updating the text/color.
class _DndToggle extends StatelessWidget {
  final DndSetting setting;
  final UserAvailabilityType userAvailabilityType;

  const _DndToggle({
    required this.setting,
    required this.userAvailabilityType,
  });

  String _text(BuildContext context) {
    if (setting.value == true) {
      return context.msg.main.settings.list.calling.availability.dnd.title;
    }

    if (userAvailabilityType == UserAvailabilityType.notAvailable) {
      return context
          .msg.main.settings.list.calling.availability.notAvailable.title;
    }

    if (userAvailabilityType == UserAvailabilityType.elsewhere) {
      return context
          .msg.main.settings.list.calling.availability.elsewhere.title;
    }

    return context.msg.main.settings.list.calling.availability.available.title;
  }

  Color _color(BuildContext context) => setting.value == true
      ? context.brand.theme.colors.dnd
      : userAvailabilityType.asColor(context);

  Color _accentColor(BuildContext context) => setting.value == true
      ? context.brand.theme.colors.dndAccent
      : userAvailabilityType.asAccentColor(context);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 14,
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      _text(context),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        color: _color(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            child: FlutterSwitch(
              value: setting.value,
              inactiveIcon: Icon(
                VialerSans.available,
                color: _accentColor(context),
              ),
              activeIcon: Icon(
                VialerSans.dnd,
                color: _accentColor(context),
              ),
              switchBorder: Border.all(
                color: _color(context),
                width: 2.0,
              ),
              height: 32,
              width: 70,
              padding: 4,
              activeColor: _accentColor(context),
              inactiveColor: _accentColor(context),
              activeToggleColor: _color(context),
              inactiveToggleColor: _color(context),
              onToggle: (dnd) => defaultOnChanged(
                context,
                setting.copyWith(value: dnd),
              ),
            ),
          )
        ],
      ),
      decoration: BoxDecoration(
        color: _accentColor(context),
        borderRadius: const BorderRadius.all(
          Radius.circular(40),
        ),
      ),
    );
  }
}

enum UserAvailabilityType { available, elsewhere, notAvailable }

extension Display on UserAvailabilityType {
  Color asColor(BuildContext context) {
    if (this == UserAvailabilityType.elsewhere) {
      return context.brand.theme.colors.availableElsewhere;
    } else if (this == UserAvailabilityType.notAvailable) {
      return context.brand.theme.colors.notAvailable;
    } else {
      return context.brand.theme.colors.available;
    }
  }

  Color asAccentColor(BuildContext context) {
    if (this == UserAvailabilityType.elsewhere) {
      return context.brand.theme.colors.availableElsewhereAccent;
    } else if (this == UserAvailabilityType.notAvailable) {
      return context.brand.theme.colors.notAvailableAccent;
    } else {
      return context.brand.theme.colors.availableAccent;
    }
  }
}

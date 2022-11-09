import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/logging/remove_stored_logs.dart';
import '../../../../../domain/user/settings/app_setting.dart';
import '../../../../../domain/user/settings/call_setting.dart';
import '../../../../../domain/user/settings/settings.dart';
import '../../../../../domain/user/user.dart';
import '../../../../../domain/voipgrid/destination.dart';
import '../../../../../domain/voipgrid/fixed_destination.dart';
import '../../../../../domain/voipgrid/phone_account.dart';
import '../../../../../domain/voipgrid/web_page.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../../widgets/stylized_dropdown.dart';
import '../../../onboarding/widgets/stylized_text_field.dart';
import '../../../web_view/page.dart';
import '../../widgets/stylized_switch.dart';
import '../cubit.dart';
import 'availability_tile.dart';
import 'link_tile.dart';

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

  static Widget dnd(User user) {
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
                child: _DndToggle(user),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget username(User user) {
    return Builder(builder: (context) {
      return _userInformation(
        description: Text(
          context.msg.main.settings.list.accountInfo.username.description,
        ),
        child: _StringValue(user.email),
      );
    });
  }

  static Widget mobileNumber(
    Settings settings, {
    Key? key,
    required bool isVoipAllowed,
  }) {
    const key = CallSetting.mobileNumber;

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
              ? _StringEditSettingValue(settings, key)
              : _StringSettingValue(settings, key),
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

  static Widget usePhoneRingtone(Settings settings) {
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
          child: _BoolSettingValue(settings, CallSetting.usePhoneRingtone),
        );
      },
    );
  }

  static Widget useVoip(Settings settings) {
    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(context.msg.main.settings.list.calling.useVoip.title),
          description: Text(
            context.msg.main.settings.list.calling.useVoip.description,
          ),
          child: _BoolSettingValue(settings, CallSetting.useVoip),
        );
      },
    );
  }

  static Widget showCallsInNativeRecents(Settings settings) {
    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(
            context
                .msg.main.settings.list.calling.showCallsInNativeRecents.title,
          ),
          description: Text(
            context.msg.main.settings.list.calling.showCallsInNativeRecents
                .description(context.brand.appName),
          ),
          child: _BoolSettingValue(
            settings,
            AppSetting.showCallsInNativeRecents,
          ),
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
          child: StylizedSwitch(
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

  static Widget showClientCalls(User user) {
    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(
            context.msg.main.settings.list.calling.showClientCalls.title,
          ),
          description: Text(
            user.permissions.canSeeClientCalls
                ? context
                    .msg.main.settings.list.calling.showClientCalls.description
                : context.msg.main.settings.list.calling.showClientCalls
                    .noPermission,
          ),
          child: _BoolSettingValue(
            user.settings,
            AppSetting.showClientCalls,
            onChanged:
                user.permissions.canSeeClientCalls ? defaultOnChanged : null,
          ),
        );
      },
    );
  }

  static Widget remoteLogging(Settings settings) {
    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(context.msg.main.settings.list.debug.remoteLogging.title),
          description: Text(
            context.msg.main.settings.list.debug.remoteLogging.description,
          ),
          child: _BoolSettingValue(
            settings,
            AppSetting.remoteLogging,
            onChanged: (context, key, value) {
              // Show a popup, asking if the user wants to send their locally
              // saved logs to the remote.
              if (value == true) {
                showDialog(
                  context: context,
                  builder: (_) => _RemoteLoggingSendLogsDialog(
                    cubit: context.read<SettingsCubit>(),
                  ),
                );
              }
              defaultOnChanged(context, key, value);
            },
          ),
        );
      },
    );
  }

  static Widget echoCancellationCalibration() {
    return Builder(
      builder: (context) {
        return SettingLinkTile(
          title: Text(
            context.msg.main.settings.list.advancedSettings.troubleshooting.list
                .audio.echoCancellationCalibration.title,
          ),
          description: Text(
            context.msg.main.settings.list.advancedSettings.troubleshooting.list
                .audio.echoCancellationCalibration.description,
          ),
          onTap: () => context
              .read<SettingsCubit>()
              .performEchoCancellationCalibration(),
          showNavigationIndicator: false,
        );
      },
    );
  }

  static Widget availability(User user) {
    const key = CallSetting.availability;
    final availability = user.settings.get(key);

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
            userAvailabilityType: user.availabilityType,
            user: user,
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
                      key,
                      availability.copyWithSelectedDestination(
                        destination: destination,
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

  static Widget useMobileNumberAsFallback(Settings settings) {
    final mobileNumber = settings.get(CallSetting.mobileNumber);

    return Builder(
      builder: (context) {
        return SettingTile(
          label: Text(
            context
                .msg.main.settings.list.calling.useMobileNumberAsFallback.title,
          ),
          description: Text(
            context.msg.main.settings.list.calling.useMobileNumberAsFallback
                .description(mobileNumber),
          ),
          child: _BoolSettingValue(
            settings,
            CallSetting.useMobileNumberAsFallback,
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

  static Widget outgoingNumber(User user) {
    const key = CallSetting.outgoingNumber;
    final value = user.settings.get(key);
    final availableOutgoingNumbers = user.client?.outgoingNumbers ?? const [];

    return Builder(
      builder: (context) {
        final unlockedWidget = _StringSettingValue(
          user.settings,
          key,
          value: (number) => number is UnsuppressedOutgoingNumber
              ? number.value
              : context
                  .msg.main.settings.list.accountInfo.businessNumber.suppressed,
          bold: false,
        );

        return SettingTile(
          description: Text(
            context
                .msg.main.settings.list.accountInfo.businessNumber.description,
          ),
          childFillWidth: true,
          child: user.canChangeOutgoingNumber
              ? _EditableSettingField(
                  unlocked: Expanded(
                    child: _MultipleChoiceSettingValue<OutgoingNumber>(
                      value: value,
                      padding: const EdgeInsets.only(
                        bottom: 8,
                        right: 8,
                      ),
                      onChanged: (number) =>
                          defaultOnChanged(context, key, number),
                      isExpanded: false,
                      items: [
                        DropdownMenuItem<OutgoingNumber>(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              context.msg.main.settings.list.accountInfo
                                  .businessNumber.suppressed,
                            ),
                          ),
                          value: const OutgoingNumber.suppressed(),
                        ),
                        ...availableOutgoingNumbers.map(
                          (number) => DropdownMenuItem<OutgoingNumber>(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(number.toString()),
                            ),
                            value: number,
                          ),
                        ),
                      ],
                    ),
                  ),
                  locked: unlockedWidget,
                )
              : unlockedWidget,
        );
      },
    );
  }
}

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

class _BoolSettingValue extends StatelessWidget {
  final Settings settings;
  final SettingKey<bool> settingKey;
  final ValueChangedWithContext<bool>? onChanged;

  const _BoolSettingValue(
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

class _StringValue extends StatelessWidget {
  final String value;
  final bool bold;

  const _StringValue(
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

class _StringSettingValue<T extends Object> extends StatelessWidget {
  final Settings settings;
  final SettingKey<T> settingKey;

  /// If [T] is not [String], use this function to retrieve the
  /// desired string value of [T].
  final GetStringValue<T> value;
  final bool? bold;

  _StringSettingValue(
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
    return _StringValue(
      settingValue != null ? value(settingValue) : '',
      bold: bold,
    );
  }
}

class _EditableSettingField extends StatefulWidget {
  final Widget unlocked;
  final Widget locked;

  const _EditableSettingField({
    required this.unlocked,
    required this.locked,
  }) : super();

  @override
  _EditableSettingFieldState createState() => _EditableSettingFieldState();
}

class _EditableSettingFieldState extends State<_EditableSettingField> {
  bool _editing = false;

  void _toggleEditing() {
    setState(() {
      _editing = !_editing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _editing ? widget.unlocked : widget.locked,
        IconButton(
          onPressed: _toggleEditing,
          icon: const _EditIcon(),
        ),
      ],
    );
  }
}

class _StringEditSettingValue extends StatefulWidget {
  final Settings settings;
  final SettingKey<String> setting;
  final ValueChangedWithContext<String> onChanged;

  final String value;

  _StringEditSettingValue(
    this.settings,
    this.setting, {
    // ignore: unused_element
    this.onChanged = defaultOnChanged,
  }) : value = settings.get(setting);

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
      text: widget.value,
      selection: TextSelection.collapsed(offset: widget.value.length),
    );
  }

  void _onPressed(BuildContext context) {
    widget.onChanged(context, widget.setting, _textEditingController.text);
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
          icon: const FaIcon(FontAwesomeIcons.check),
        ),
        elevation: 0,
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            widget.value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          IconButton(
            onPressed: _toggleEditing,
            icon: const _EditIcon(),
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
  final EdgeInsets padding;

  const _MultipleChoiceSettingValue({
    super.key,
    required this.value,
    required this.items,
    this.isExpanded = false,
    required this.onChanged,
    EdgeInsets? padding,
  }) : padding = padding ?? const EdgeInsets.only(right: 16);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: StylizedDropdown<T>(
        value: items.map((item) => item.value).contains(value) ? value : null,
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

    void onDenyPressed() {
      RemoveStoredLogs()(keepPastDay: false);
      Navigator.pop(context);
    }

    void onConfirmPressed() {
      RemoveStoredLogs()(keepPastDay: true);
      Navigator.pop(context);
    }

    if (context.isAndroid) {
      return AlertDialog(
        title: title,
        content: content,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.brand.theme.colors.primary,
            ),
            onPressed: onDenyPressed,
            child: deny,
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.brand.theme.colors.primary,
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

extension AvailabilityType on User {
  UserAvailabilityType get availabilityType {
    final availability = settings.get(CallSetting.availability);

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
  final User user;
  final UserAvailabilityType userAvailabilityType;
  final bool value;

  static const _key = CallSetting.dnd;

  _DndToggle(this.user)
      : value = user.settings.get(_key),
        userAvailabilityType = user.availabilityType;

  String _text(BuildContext context, {bool? settingValue}) {
    settingValue ??= value;

    if (settingValue == true) {
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

  Color _color(BuildContext context) => value == true
      ? context.brand.theme.colors.dnd
      : userAvailabilityType.asColor(context);

  Color _accentColor(BuildContext context) => value == true
      ? context.brand.theme.colors.dndAccent
      : userAvailabilityType.asAccentColor(context);

  String _prepareVoiceOverForAccessibility(
    BuildContext context,
    bool dnd,
  ) {
    var availabilityDescription = '';

    if (userAvailabilityType == UserAvailabilityType.available) {
      availabilityDescription =
          context.msg.main.settings.list.calling.availability.dnd.currentStatus(
        dnd
            ? context.msg.main.settings.list.calling.notAvailable
            : context
                .msg.main.settings.list.calling.availability.available.title,
      );
    } else {
      availabilityDescription = _text(context, settingValue: false);
    }

    return '${context.msg.main.settings.list.calling.availability.dnd.title}. '
        '${context.msg.generic.toggle}. '
        '${dnd ? context.msg.generic.on : context.msg.generic.off}. '
        '$availabilityDescription. ';
  }

  Future<bool> _toggleDndSetting(BuildContext context) async {
    final newValue = !value;

    return defaultOnChanged(context, _key, newValue).then((_) => newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _prepareVoiceOverForAccessibility(context, value),
      enabled: true,
      container: true,
      onTap: () => _toggleDndSetting(context).then(
        (dnd) => SemanticsService.announce(
          _prepareVoiceOverForAccessibility(context, dnd),
          Directionality.of(context),
        ),
      ),
      child: ExcludeSemantics(
        child: Container(
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
                  value: value,
                  inactiveIcon: SizedBox(
                    width: 28,
                    height: 28,
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.bell,
                        color: _accentColor(context),
                      ),
                    ),
                  ),
                  activeIcon: SizedBox(
                    width: 28,
                    height: 28,
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.bellSlash,
                        color: _accentColor(context),
                      ),
                    ),
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
                  onToggle: (_) => _toggleDndSetting(context),
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

class _EditIcon extends StatelessWidget {
  const _EditIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const FaIcon(
      FontAwesomeIcons.pen,
      size: 22,
    );
  }
}

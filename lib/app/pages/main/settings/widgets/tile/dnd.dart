import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';
import 'availability.dart';
import 'value.dart';

class DndTile extends StatelessWidget {
  const DndTile(
    this.user, {
    this.enabled = true,
    super.key,
  });

  final User user;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ).copyWith(
        top: 0,
      ),
      child: Row(
        children: [
          Expanded(
            child: _DndToggle(
              user,
              enabled: enabled,
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsible for rendering the dnd toggle but also the current state of the
/// user's availability by updating the text/color.
class _DndToggle extends StatelessWidget {
  _DndToggle(
    this.user, {
    this.enabled = true,
  })  : _value = user.settings.get(_key),
        _userAvailabilityType = user.availabilityType;
  final User user;

  final UserAvailabilityType _userAvailabilityType;
  final bool _value;
  final bool enabled;

  static const _key = CallSetting.dnd;

  String _text(BuildContext context, {bool? settingValue}) {
    settingValue ??= _value;

    if (settingValue == true) {
      return context.msg.main.settings.list.calling.availability.dnd.title;
    }

    if (_userAvailabilityType == UserAvailabilityType.notAvailable) {
      return context
          .msg.main.settings.list.calling.availability.notAvailable.title;
    }

    if (_userAvailabilityType == UserAvailabilityType.elsewhere) {
      return context
          .msg.main.settings.list.calling.availability.elsewhere.title;
    }

    return context.msg.main.settings.list.calling.availability.available.title;
  }

  Color _color(BuildContext context) => _value == true
      ? context.brand.theme.colors.userAvailabilityUnavailableAccent
      : _userAvailabilityType.asColor(context);

  Color _accentColor(BuildContext context) => _value == true
      ? context.brand.theme.colors.userAvailabilityUnavailable
      : _userAvailabilityType.asAccentColor(context);

  String _prepareVoiceOverForAccessibility(
    BuildContext context,
    bool dnd,
  ) {
    var availabilityDescription = '';

    if (_userAvailabilityType == UserAvailabilityType.available) {
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
    final newValue = !_value;

    return defaultOnChanged(context, _key, newValue).then((_) => newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _prepareVoiceOverForAccessibility(context, _value),
      enabled: true,
      container: true,
      onTap: () => unawaited(
        _toggleDndSetting(context).then(
          (dnd) => SemanticsService.announce(
            _prepareVoiceOverForAccessibility(context, dnd),
            Directionality.of(context),
          ),
        ),
      ),
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _accentColor(context),
            borderRadius: const BorderRadius.all(
              Radius.circular(40),
            ),
          ),
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
                  value: _value,
                  disabled: !enabled,
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
                  ),
                  height: 32,
                  activeColor: _accentColor(context),
                  inactiveColor: _accentColor(context),
                  activeToggleColor: _color(context),
                  inactiveToggleColor: _color(context),
                  onToggle: (_) => unawaited(_toggleDndSetting(context)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

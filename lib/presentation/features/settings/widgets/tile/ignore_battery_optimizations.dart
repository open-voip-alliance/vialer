import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../../../shared/widgets/stylized_switch.dart';
import 'widget.dart';

class IgnoreBatteryOptimizationsTile extends StatelessWidget {
  const IgnoreBatteryOptimizationsTile({
    required this.hasIgnoreBatteryOptimizationsPermission,
    required this.onChanged,
    super.key,
  });

  final bool hasIgnoreBatteryOptimizationsPermission;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      label: Text(
        context.msg.main.settings.list.calling.ignoreBatteryOptimizations.title,
      ),
      description: Text(
        context.msg.main.settings.list.calling.ignoreBatteryOptimizations
            .description,
      ),
      child: StylizedSwitch(
        value: hasIgnoreBatteryOptimizationsPermission,
        // It is not possible to disable battery optimization via the app
        // so if we have the permission, this should just be disabled.
        onChanged: !hasIgnoreBatteryOptimizationsPermission ? onChanged : null,
      ),
    );
  }
}

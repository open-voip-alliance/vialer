import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../resources/localizations.dart';
import '../../../widgets/stylized_switch.dart';
import 'widget.dart';

class IgnoreBatteryOptimizationsTile extends StatelessWidget {
  final bool hasIgnoreBatteryOptimizationsPermission;
  final Function(bool) onChanged;

  const IgnoreBatteryOptimizationsTile({
    super.key,
    required this.hasIgnoreBatteryOptimizationsPermission,
    required this.onChanged,
  });

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

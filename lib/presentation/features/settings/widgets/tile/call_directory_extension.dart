import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/util/brand.dart';

import '../../../../resources/messages.i18n.dart';
import '../../../../shared/widgets/stylized_switch.dart';
import 'widget.dart';

class CallDirectoryExtensionTile extends StatelessWidget {
  const CallDirectoryExtensionTile({
    required this.isCallDirectoryExtensionEnabled,
    required this.onChanged,
    super.key,
  });

  final bool isCallDirectoryExtensionEnabled;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      label: Text(context.strings.title),
      description: Text(context.strings.description(context.brand.appName)),
      child: StylizedSwitch(
        value: isCallDirectoryExtensionEnabled,
        onChanged: onChanged,
      ),
    );
  }
}

extension on BuildContext {
  CallDirectoryExtensionCallingListSettingsMainMessages get strings =>
      msg.main.settings.list.calling.callDirectoryExtension;
}

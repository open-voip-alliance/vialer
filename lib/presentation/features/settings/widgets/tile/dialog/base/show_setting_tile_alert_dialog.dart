import 'package:flutter/material.dart';
import 'package:vialer/data/models/user/settings/settings.dart';

import '../../value.dart';

/// Shows the user a dialog to update their setting and will automatically
/// execute [defaultOnSettingChanged] if the user chooses to save the new
/// value.
Future<T?> showSettingTileAlertDialogAndSaveOnCompletion<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required SettingKey settingKey,
}) async {
  final newValue = await showDialog<T>(
    context: context,
    builder: builder,
  );

  if (newValue != null) {
    await defaultOnSettingChanged(
      context,
      settingKey,
      newValue,
    );
  }

  return newValue;
}

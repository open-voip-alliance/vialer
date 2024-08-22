import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/version_info.vialer.dart';

import '../../controllers/cubit.dart';
import '../settings_subpage.dart';
import 'logs.dart';

class VersionInfoSubPage extends StatelessWidget {
  const VersionInfoSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final versionInfo = {
      'Flutter': vialerVersionInfo.flutter,
      'Dart': vialerVersionInfo.dart,
      'Flutter Phone Lib': vialerVersionInfo.flutterPhoneLib,
      'iOS Phone Lib': vialerVersionInfo.iOSPhoneLib,
      'Android Phone Lib': vialerVersionInfo.androidPhoneLib,
    };

    return SettingsSubPage(
      cubit: context.watch<SettingsCubit>(),
      title: context.msg.main.settings.list.advancedSettings.troubleshooting
          .versionInfo.title,
      child: (state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: BasicDividedListView(
            itemBuilder: (_, index) {
              final type = versionInfo.keys.toList()[index];
              final version = versionInfo[type]!;
              final disabled = (type.contains('iOS') && Platform.isAndroid) ||
                  (type.contains('Android') && Platform.isIOS);

              return ListTile(
                title: Text(type),
                subtitle: Text(version),
                enabled: !disabled,
              );
            },
            itemCount: versionInfo.length,
          ),
        );
      },
    );
  }
}

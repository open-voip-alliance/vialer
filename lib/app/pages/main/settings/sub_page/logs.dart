import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/legacy/storage.dart';

import '../../../../resources/localizations.dart';
import '../cubit.dart';
import 'widget.dart';

class LogSubPage extends StatelessWidget {
  const LogSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(
      const Duration(seconds: 1),
      builder: (context) {
        final cubit = context.watch<SettingsCubit>();

        final rawLogs = dependencyLocator<StorageRepository>().logs;
        final logs = rawLogs!.split('\n').reversed.toList();

        return SettingsSubPage(
          cubit: cubit,
          title: context.msg.main.settings.list.advancedSettings.troubleshooting
              .logs.title,
          child: (state) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: logs.isNotEmpty
                  ? ListView.separated(
                      itemBuilder: (context, index) {
                        return Text(logs[index]);
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemCount: logs.length,
                    )
                  : Text(
                      context.msg.main.settings.list.advancedSettings
                          .troubleshooting.logs.none,
                    ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:vialer/data/repositories/legacy/storage.dart';
import 'package:vialer/dependency_locator.dart';

import '../../../../resources/localizations.dart';
import '../../controllers/cubit.dart';
import '../settings_subpage.dart';

class LogSubPage extends StatelessWidget {
  const LogSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(
      const Duration(seconds: 1),
      builder: (context) {
        final cubit = context.watch<SettingsCubit>();

        final rawLogs = dependencyLocator<StorageRepository>().logs;
        final logs = rawLogs != null
            ? rawLogs.split('\n').reversed.toList()
            : <String>[];

        return SettingsSubPage(
          cubit: cubit,
          title: context.msg.main.settings.list.advancedSettings.troubleshooting
              .logs.title,
          child: (state) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: BasicDividedListView(
                itemBuilder: (_, index) {
                  return Text(logs[index]);
                },
                itemCount: logs.length,
                fallback: (_) {
                  return Text(
                    context.msg.main.settings.list.advancedSettings
                        .troubleshooting.logs.none,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class BasicDividedListView extends StatelessWidget {
  const BasicDividedListView({
    required this.itemBuilder,
    required this.itemCount,
    this.fallback,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext)? fallback;

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0 && fallback != null) {
      return fallback!(context);
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        return itemBuilder(context, index);
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
      itemCount: itemCount,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:recase/recase.dart';

import '../../controllers/cubit.dart';
import '../settings_subpage.dart';
import 'logs.dart';

class InstalledApplicationsSubPage extends StatelessWidget {
  const InstalledApplicationsSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: InstalledApps.getInstalledApps(),
      initialData: <AppInfo>[],
      builder: (context, data) {
        final apps = data.data ?? [];

        return SettingsSubPage(
          cubit: context.watch<SettingsCubit>(),
          title: 'Installed Applications',
          child: (state) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: BasicDividedListView(
                itemBuilder: (_, index) {
                  return _AppInfoItem(apps[index]);
                },
                itemCount: apps.length,
                fallback: (_) {
                  return Text('Loading installed applications');
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _AppInfoItem extends StatelessWidget {
  const _AppInfoItem(this.app);

  final AppInfo app;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: app.icon?.isNotEmpty == true ? Image.memory(app.icon!) : null,
      title: Text(ReCase(app.name ?? '').sentenceCase),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(app.packageName ?? ''),
          Text(app.versionCode.toString()),
          Text(app.versionName ?? ''),
        ],
      ),
    );
  }
}

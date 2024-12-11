import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/features/colltacts/controllers/cubit.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/util/context_extensions.dart';

import '../../../../../../data/models/colltacts/colltact_tab.dart';
import '../../../../resources/messages.i18n.dart';

class ColltactsTabBar extends StatelessWidget {
  const ColltactsTabBar({this.controller, super.key});

  final TabController? controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ColltactsTabsCubit, List<ColltactTab>>(
      builder: (context, tabs) {
        return TabBar(
          controller: controller,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          labelPadding: const EdgeInsets.only(
            top: 18,
            bottom: 8,
          ),
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: context.colors.grey1,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: tabs.widgets(
            (tab) => switch (tab) {
              ColltactTab.contacts =>
                Text(context.strings.contactsTabTitle.toUpperCase()),
              ColltactTab.sharedContact =>
                Text(context.strings.sharedTabTitle.toUpperCase()),
              ColltactTab.colleagues =>
                Text(context.strings.colleaguesTabTitle.toUpperCase()),
            },
          ),
        );
      },
    );
  }
}

extension on BuildContext {
  TabBarContactsMainMessages get strings => msg.main.contacts.tabBar;
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../../../../data/models/user/user.dart';
import '../../../../../data/repositories/voipgrid/user_permissions.dart';
import '../../business_availability/widgets/temporary_redirect/setting_tile.dart';
import '../controllers/cubit.dart';
import '../widgets/tile/category/portal_links.dart';
import '../widgets/tile/category/temporary_redirect.dart';
import '../widgets/tile/link/calls.dart';
import '../widgets/tile/link/dial_plan.dart';
import '../widgets/tile/link/opening_hours.dart';
import '../widgets/tile/link/stats.dart';
import 'settings_subpage.dart';

class ClientSubPage extends StatelessWidget {
  const ClientSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final user = state.user;
        final cubit = context.watch<SettingsCubit>();

        return SettingsSubPage(
          cubit: cubit,
          title:
              context.msg.main.settings.subPage.client.title(user.client.name),
          child: (state) {
            return ListView(
              children: [
                if (user.hasPermission(Permission.canChangeTemporaryRedirect))
                  const TemporaryRedirectCategory(
                    children: [
                      TemporaryRedirectSettingTile(),
                    ],
                  ),
                if (user.canViewAtLeastOneWebView)
                  PortalLinksCategory(
                    children: [
                      if (user.hasPermission(Permission.canSeeClientCalls))
                        const CallsLinkTile(),
                      if (user.hasPermission(Permission.canViewDialPlans))
                        const DialPlanLinkTile(),
                      if (cubit.shouldShowOpeningHoursBasic &&
                          user.client.openingHoursModules.isNotEmpty)
                        OpeningHoursLinkTile(user),
                      if (user.hasPermission(Permission.canViewStats))
                        const StatsLinkTile(),
                    ],
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

extension UserPermissions on User {
  bool get canViewClientSubPage => [
        hasPermission(Permission.canChangeTemporaryRedirect),
        client.openingHoursModules.isNotEmpty,
        hasPermission(Permission.canSeeClientCalls),
        hasPermission(Permission.canViewDialPlans),
        hasPermission(Permission.canViewStats),
      ].hasAtLeastOne;

  bool get canViewAtLeastOneWebView => [
        client.openingHoursModules.isNotEmpty,
        hasPermission(Permission.canSeeClientCalls),
        hasPermission(Permission.canViewDialPlans),
        hasPermission(Permission.canViewStats),
      ].hasAtLeastOne;
}

extension on Iterable<bool> {
  bool get hasAtLeastOne => any((element) => element);
}

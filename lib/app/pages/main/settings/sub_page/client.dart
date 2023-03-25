import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/user/user.dart';
import '../../../../resources/localizations.dart';
import '../../business_availability/temporary_redirect/setting_tile.dart';
import '../cubit.dart';
import '../widgets/tile/category/portal_links.dart';
import '../widgets/tile/category/temporary_redirect.dart';
import '../widgets/tile/link/calls.dart';
import '../widgets/tile/link/dial_plan.dart';
import '../widgets/tile/link/opening_hours.dart';
import '../widgets/tile/link/stats.dart';
import 'widget.dart';

class ClientSubPage extends StatelessWidget {
  const ClientSubPage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final user = state.user;
        final cubit = context.watch<SettingsCubit>();

        return SettingsSubPage(
          cubit: cubit,
          title: Text(
            context.msg.main.settings.subPage.client.title(user.client.name),
          ),
          children: (state) {
            return [
              if (user.permissions.canChangeTemporaryRedirect)
                const TemporaryRedirectCategory(
                  children: [
                    TemporaryRedirectSettingTile(),
                  ],
                ),
              if (user.canViewAtLeastOneWebView)
                PortalLinksCategory(
                  children: [
                    if (user.permissions.canSeeClientCalls) ...[
                      const CallsLinkTile(),
                      const SizedBox(height: 10),
                    ],
                    if (user.permissions.canViewDialPlans) ...[
                      const DialPlanLinkTile(),
                      const SizedBox(height: 10),
                    ],
                    if (cubit.shouldShowOpeningHoursBasic &&
                        user.client.openingHours.isNotEmpty) ...[
                      OpeningHoursLinkTile(user),
                      const SizedBox(height: 10),
                    ],
                    if (user.permissions.canViewStats) ...[
                      const StatsLinkTile(),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
            ];
          },
        );
      },
    );
  }
}

extension UserPermissions on User {
  bool get canViewClientSubPage => [
        permissions.canChangeTemporaryRedirect,
        client.openingHours.isNotEmpty,
        permissions.canSeeClientCalls,
        permissions.canViewDialPlans,
        permissions.canViewStats,
      ].hasAtLeastOne;

  bool get canViewAtLeastOneWebView => [
        client.openingHours.isNotEmpty,
        permissions.canSeeClientCalls,
        permissions.canViewDialPlans,
        permissions.canViewStats,
      ].hasAtLeastOne;
}

extension on Iterable<bool> {
  bool get hasAtLeastOne => any((element) => element);
}

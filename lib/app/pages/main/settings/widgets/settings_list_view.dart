import 'package:flutter/material.dart';
import 'package:dartx/dartx.dart';

import '../../../../entities/categorized_info.dart';
import '../../../../entities/category.dart';
import '../../../../entities/setting_info.dart';
import '../../../../entities/setting_route.dart';
import '../../../../entities/setting_route_info.dart';

import '../../../../../domain/entities/setting.dart';

import '../../../../mappers/category.dart';
import '../../../../mappers/setting.dart';
import '../../../../mappers/setting_route.dart';

import 'tile_category.dart';
import 'value_tile.dart';
import 'page_tile.dart';

class SettingsListView extends StatelessWidget {
  final Iterable<Setting> settings;
  final List<Category> allowedCategories;
  final ValueChanged<Setting> onSettingChanged;
  final ValueChanged<SettingRouteInfo> onRouteLinkTapped;

  /// Which route we're on. Determines what settings and page links to show.
  final SettingRoute route;

  /// Extra children shown after all settings/page links.
  final List<Widget> children;

  const SettingsListView({
    Key key,
    @required this.route,
    @required this.settings,
    @required this.allowedCategories,
    @required this.onSettingChanged,
    this.onRouteLinkTapped,
    this.children = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canAccessTroubleshooting =
        settings.get<ShowTroubleshootingSettingsSetting>()?.value ?? false;

    return ListView(
      padding: const EdgeInsets.only(
        top: 8,
      ),
      children: [
        ...Category.values
            .where(allowedCategories.contains)
            .map((c) => c.toInfo(context))
            .where((i) => i.route == route)
            .sortedBy((i) => i.order)
            .map(
              (categoryInfo) => MapEntry(
                categoryInfo,
                <CategorizedInfo>[
                  ...settings.map((s) => s.toInfo(context)).whereNotNull(),
                  // Only show page links on the main page.
                  if (route == SettingRoute.main)
                    ...SettingRoute.values
                        .where(
                          (p) =>
                              p != SettingRoute.main &&
                              // Show troubleshooting only if allowed.
                              (canAccessTroubleshooting ||
                                  p != SettingRoute.troubleshooting),
                        )
                        .map((p) => p.toInfo(context))
                ]
                    .where((i) => i.category == categoryInfo.item)
                    .sortedBy((i) => i.order),
              ),
            )
            // Don't show categories that have no items.
            .where((entry) => entry.value.isNotEmpty)
            .mapEntries(
              (categoryInfo, infos) => SettingTileCategory(
                info: categoryInfo,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(top: 16),
                children: [
                  ...infos.map(
                    (info) => info is SettingInfo
                        ? SettingValueTile(
                            info,
                            onChanged: onSettingChanged,
                          )
                        : info is SettingRouteInfo
                            ? SettingRouteTile(
                                info,
                                onTap: () => onRouteLinkTapped?.call(info),
                              )
                            : throw UnsupportedError(
                                'Vialer error: Unknown info: $info',
                              ),
                  ),
                ],
              ),
            ),
        ...children,
      ],
    );
  }
}

extension _MapEntries<K, V> on Iterable<MapEntry<K, V>> {
  Iterable<T> mapEntries<T>(T Function(K key, V value) mapper) =>
      map((e) => mapper(e.key, e.value));
}

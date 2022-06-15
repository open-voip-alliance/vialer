import 'package:dartx/dartx.dart';
import 'package:json_annotation/json_annotation.dart';

part 'navigation_destination.g.dart';

@JsonEnum(alwaysCreate: true, fieldRename: FieldRename.kebab)
enum NavigationDestination {
  dialer,
  contacts,
  recents,
  settings,
  telephony,
  feedback,
  calls,
  stats,
  dialPlan,
  logout,
}

extension Serialization on List<NavigationDestination?> {
  List<String> toJson() =>
          map((e) => _$NavigationDestinationEnumMap[e])
          .filterNotNull()
          .toList();
}

extension Deserialization on List<String> {
  List<NavigationDestination> fromJson() => filterNotNull()
      // If we have renamed or removed an enum we will ignore it, this shouldn't
      // be necessary but it's better than the app crashing.
      .filter((e) => _$NavigationDestinationEnumMap.containsValue(e))
      .map((e) => $enumDecode(_$NavigationDestinationEnumMap, e))
      .toList();
}

class NavigationDestinations {
  static final maximumSelected = 4;
  static final minimumSelected = 1;
}

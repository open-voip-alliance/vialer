import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../entities/navigation_destination.dart';

class NavigationRepository {
  late SharedPreferences _preferences;

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static const _selectedNavigationDestinationsKey =
      'selected_navigation_destinations';

  List<NavigationDestination>? get selectedNavigationDestinations {
    final stored = _preferences.getString(_selectedNavigationDestinationsKey);

    if (stored == null) return null;

    return (json.decode(stored) as List<dynamic>)
        .cast<String>()
        .fromJson();
  }

  set selectedNavigationDestinations(
    List<NavigationDestination>? destinations,
  ) {
    if (destinations == null) return;

    _preferences.setString(
      _selectedNavigationDestinationsKey,
      json.encode(destinations.toJson()),
    );
  }
}

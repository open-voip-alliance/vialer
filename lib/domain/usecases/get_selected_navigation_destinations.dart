import 'dart:core';
import 'dart:io';

import '../../dependency_locator.dart';
import '../entities/navigation_destination.dart';
import '../repositories/navigation.dart';
import '../use_case.dart';

class GetSelectedNavigationDestinationsUseCase extends UseCase {
  final _navigationRepository = dependencyLocator<NavigationRepository>();

  Future<List<NavigationDestination>> call() async {
    final selected = _navigationRepository.selectedNavigationDestinations;

    return selected != null ? selected : defaultDestinations;
  }

  List<NavigationDestination> get defaultDestinations => [
    if (Platform.isIOS) NavigationDestination.dialer,
    NavigationDestination.contacts,
    NavigationDestination.recents,
    NavigationDestination.settings,
  ];
}
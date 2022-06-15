import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/util/equatable.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/entities/navigation_destination.dart';
import '../../../../../domain/repositories/navigation.dart';
import '../../../../../domain/usecases/get_selected_navigation_destinations.dart';
import '../../../../../domain/usecases/logout.dart';
import '../../../../util/loggable.dart';

class NavigationCubit extends Cubit<NavigationState> with Loggable {
  final _getSelectedNavigation = GetSelectedNavigationDestinationsUseCase();
  final _navigationRepository = dependencyLocator<NavigationRepository>();
  final _logout = LogoutUseCase();

  NavigationCubit() : super(const NavigationUpdating([])) {
    initialize();
  }

  void initialize() async {
    emit(NavigationLocked(await _getSelectedNavigation()));
  }

  void addSelectedDestination(NavigationDestination navigation) async {
    final selected = await _getSelectedNavigation();

    emit(NavigationUpdating(selected));

    if (selected.contains(navigation)) {
      selected.remove(navigation);

      if (selected.length < NavigationDestinations.minimumSelected) {
        emit(NavigationTooFewSelected(await _getSelectedNavigation()));
        return;
      }
    } else {
      if (selected.length >= NavigationDestinations.maximumSelected) {
        emit(NavigationTooManySelected(selected));
        return;
      }

      selected.add(navigation);
    }

    _navigationRepository.selectedNavigationDestinations = selected;
    emit(NavigationUpdated(selected));
  }

  void lock() {
    emit(NavigationLocked(state.selected));
  }

  void unlock() {
    emit(NavigationUnlocked(state.selected));
  }

  Future<void> logout() async {
    logger.info('Logging out');
    await _logout();
    logger.info('Logged out');
  }
}

abstract class NavigationState extends Equatable {
  final List<NavigationDestination> selected;

  const NavigationState(this.selected);

  @override
  List<Object?> get props => selected;
}

class NavigationUnlocked extends NavigationState {
  const NavigationUnlocked(List<NavigationDestination> selected)
      : super(selected);
}

class NavigationLocked extends NavigationState {
  const NavigationLocked(List<NavigationDestination> selected)
      : super(selected);
}

class NavigationUpdating extends NavigationUnlocked {
  const NavigationUpdating(List<NavigationDestination> selected)
      : super(selected);
}

class NavigationUpdated extends NavigationUnlocked {
  const NavigationUpdated(List<NavigationDestination> selected)
      : super(selected);
}

class NavigationTooManySelected extends NavigationUnlocked {
  const NavigationTooManySelected(List<NavigationDestination> selected)
      : super(selected);
}

class NavigationTooFewSelected extends NavigationUnlocked {
  const NavigationTooFewSelected(List<NavigationDestination> selected)
      : super(selected);
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dependency_locator.dart';
import '../../../domain/entities/navigation_destination.dart';
import '../../../domain/events/event_bus.dart';
import '../../../domain/events/user_did_navigate.dart';

class MainState {
  const MainState();
}

class MainCubit extends Cubit<MainState> {
  final _eventBus = dependencyLocator<EventBus>();

  MainCubit() : super(const MainState());

  void broadcastNavigation(
    NavigationDestination? from,
    NavigationDestination to,
  ) =>
      _eventBus.broadcast(
        UserDidNavigate(from, to),
      );
}

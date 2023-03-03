import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dependency_locator.dart';
import '../../../domain/event/event_bus.dart';
import '../../../domain/voipgrid/rate_limit_reached_event.dart';
import 'state.dart';

export 'state.dart';

class RateLimitWarningCubit extends Cubit<RateLimitWarningState> {
  late final _eventBus = dependencyLocator<EventBusObserver>();

  RateLimitWarningCubit() : super(const RateLimitWarningState.none()) {
    _eventBus.on<RateLimitReachedEvent>((event) {
      emit(RateLimitWarningState.limited(event.url));
    });
  }
}

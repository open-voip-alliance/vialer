import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/data/API/resgate/resgate.dart';
import 'package:vialer/data/models/user/user.dart';

import '../../../../../../data/models/colltacts/colltact.dart';
import '../../../../../../data/models/event/event_bus.dart';
import '../../../../../../data/models/relations/colleagues/colleague.dart';
import '../../../../../../data/models/relations/events/colleague_list_did_change.dart';
import '../../../../../../data/models/user/settings/app_setting.dart';
import '../../../../../../data/repositories/voipgrid/user_permissions.dart';
import '../../../../../../dependency_locator.dart';
import '../../../../../../domain/usecases/authentication/user_was_logged_out.dart';
import '../../../../../../domain/usecases/relations/colleagues/should_show_colleagues.dart';
import '../../../../../../domain/usecases/user/get_logged_in_user.dart';
import '../../../../../../domain/usecases/user/settings/change_setting.dart';
import '../../../../shared/controllers/caller/cubit.dart';
import 'state.dart';

export 'state.dart';

class ColleaguesCubit extends Cubit<ColleaguesState> {
  ColleaguesCubit(this._caller)
      : super(
          const ColleaguesState.loading(
            showOnlineColleaguesOnly: false,
          ),
        ) {
    _eventBus
      ..on<UserWasLoggedOutEvent>((_) async {
        emit(
          ColleaguesState.loading(
            showOnlineColleaguesOnly: state.showOnlineColleaguesOnly,
          ),
        );
      })
      ..on<ColleagueListDidChangeEvent>(_colleaguesWereChanged);
  }

  late final _shouldShowColleagues = ShouldShowColleagues();
  final _resgate = dependencyLocator<Resgate>();
  final _eventBus = dependencyLocator<EventBusObserver>();
  final _getUser = GetLoggedInUserUseCase();
  final _changeSetting = ChangeSettingUseCase();

  final CallerCubit _caller;

  List<Colleague> get _colleagues => state.map(
        loading: (_) => [],
        loaded: (state) => state.colleagues,
      );

  bool get shouldShowColleagues =>
      _shouldShowColleagues() &&
      (_colleagues.isNotEmpty || state is LoadingColleagues);

  bool get canViewColleagues =>
      _getUser().hasPermission(Permission.canViewColleagues);

  bool get showOnlineColleaguesOnly =>
      _getUser().settings.get(AppSetting.showOnlineColleaguesOnly);

  set showOnlineColleaguesOnly(bool value) {
    emit(state.copyWith(showOnlineColleaguesOnly: value));
    unawaited(_changeSetting(AppSetting.showOnlineColleaguesOnly, value));
  }

  void _colleaguesWereChanged(ColleagueListDidChangeEvent event) {
    if (isClosed) return;

    final colleagues = event.colleagues;

    emit(
      ColleaguesState.loaded(
        // As a new list otherwise the equality check will not read this as a
        // new state.
        colleagues.toList(),
        showOnlineColleaguesOnly: showOnlineColleaguesOnly,
        upToDate: _resgate.isConnected,
      ),
    );
  }

  /// Refresh the WebSocket, disconnecting and reconnecting to load all
  /// new data.
  ///
  /// This should only be called on a specific user-action as it has a large
  /// amount of overhead.
  Future<void> refresh() async => _resgate.refresh();

  Future<void> call(String destination) =>
      _caller.call(destination, origin: CallOrigin.colleagues);

  Colltact refreshColltactColleague(Colltact colltact) {
    if (state is ColleaguesLoaded && colltact is ColltactColleague) {
      final colleague = (state as ColleaguesLoaded).colleagues.firstWhereOrNull(
            (colleague) =>
                colleague.id == (colltact as ColltactColleague).colleague.id,
          );
      if (colleague != null) colltact = Colltact.colleague(colleague);
    }
    return colltact;
  }
}

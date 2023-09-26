import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:res_client/event.dart';
import 'package:res_client/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:res_client/client.dart';
import 'package:vialer/domain/feature/has_feature.dart';

import '../../../../../../../domain/feature/feature.dart';
import '../../../../../../../domain/user/get_logged_in_user.dart';
import '../../../../../../../domain/user/user.dart';

part 'queue_statistics.freezed.dart';
part 'queue_statistics.g.dart';

@riverpod
class QueueStatistics extends _$QueueStatistics {
  User get _user => GetLoggedInUserUseCase()();

  QueueStatistics() {
    connect();
  }

  @override
  QueueStatisticsState build() {
    return QueueStatisticsState.loading();
  }

  void connect() async {
    if (!hasFeature(Feature.queueStatistics)) return;

    final url = 'wss://resgate.prod.holodeck.spindle.dev';
    final client = await ResClient()
      ..reconnect(Uri.parse(url));

    await client.auth(
      'usertoken',
      'login',
      params: {'token': _user.token},
    );

    return _onAuthenticated(client);
  }

  Future<void> _onAuthenticated(ResClient client) async {
    await client.subscribe('dashboard.client.${_user.client.uuid}', null);

    final initialData = client.get('dashboard.client.${_user.client.uuid}');

    if (initialData?.item is ResCollection) {
      final items = (initialData!.item as ResCollection).items;

      for (final item in items) {
        if (item is ResModel) {
          _updateState(item.rid, item.toJson());
        }
      }
    }

    client.events.listen((event) {
      if (event is ModelChangedEvent) {
        _updateState(event.rid, event.newProps);
      }
    });
  }

  void _updateState(String name, Map<String, dynamic> data) {
    var stats = state.map(
      loading: (_) => <String, IndividualQueueStatistics>{},
      loaded: (loaded) => loaded.stats,
    );

    stats = Map.from(stats);

    var queueStats = stats[name];

    if (queueStats != null) {
      final queueData = queueStats.asData()..addAll(data);
      queueStats = IndividualQueueStatistics(queueData);
    } else {
      queueStats = IndividualQueueStatistics(data);
    }

    stats[name] = queueStats;

    state = QueueStatisticsState.loaded(stats: stats);
  }

  void selectSpecificQueue(String selected) {
    final loaded = this.state;

    if (loaded is Loaded && loaded.stats.containsKey(selected)) {
      state = loaded.copyWith(selectedQueue: selected);
    }
  }
}

@freezed
sealed class QueueStatisticsState with _$QueueStatisticsState {
  const QueueStatisticsState._();

  const factory QueueStatisticsState.loading() = Loading;
  const factory QueueStatisticsState.loaded({
    @Default(null) String? selectedQueue,
    required Map<String, IndividualQueueStatistics> stats,
  }) = Loaded;

  IndividualQueueStatistics get selectedStatistics {
    final self = this as Loaded;

    final selectedQueue = self.selectedQueue ?? self.stats.keys.first;

    return self.stats[selectedQueue]!;
  }
}

class IndividualQueueStatistics {
  IndividualQueueStatistics(this._data);

  final Map<String, dynamic> _data;

  Map<String, dynamic> asData() => _data;

  int get callersInQueue => _fromKey('waiting_callers');
  int get activeCalls => _fromKey('total_active_calls');
  int get totalAgents => _fromKey('total_agents');
  int get loggedInAgents => _fromKey('logged_in_agents');
  int get dndAgents => _fromKey('dnd_agents');

  int _fromKey(String key) => _data.getOrElse(key, () => 0) as int;
}

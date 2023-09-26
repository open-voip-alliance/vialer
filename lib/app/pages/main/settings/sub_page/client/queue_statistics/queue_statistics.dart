import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:res_client/client.dart';

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

  void connect() {
    final url = 'wss://resgate.prod.holodeck.spindle.dev';
    final client = ResClient()
      ..reconnect(Uri.parse(url))
      ..auth(
        'usertoken',
        'login',
        params: {'token': _user.token},
      )
      ..subscribe('dashboard.client.${_user.client.uuid}', null);

    client.events.listen((event) {
      print("TEST123 $event");
    });
  }
}

@freezed
sealed class QueueStatisticsState with _$QueueStatisticsState {
  const factory QueueStatisticsState.loading() = Loading;
  const factory QueueStatisticsState.loaded({
    required int callersInQueue,
    required int activeCalls,
  }) = Loaded;
}

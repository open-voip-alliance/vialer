import 'package:connectivity/connectivity.dart';

import '../connectivity_status.dart';
import 'mappers/connectivity_status.dart';

class ConnectivityRepository {
  Future<ConnectivityStatus> get currentStatus {
    return Connectivity()
        .checkConnectivity()
        .then((result) => result.toDomainEntity());
  }

  Stream<ConnectivityStatus> get statusStream {
    return Connectivity()
        .onConnectivityChanged
        .map((result) => result.toDomainEntity());
  }
}

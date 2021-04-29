import 'package:connectivity/connectivity.dart';

import '../connectivity_type.dart';
import 'mappers/connectivity_status.dart';

class ConnectivityRepository {
  Future<ConnectivityType> get currentType {
    return Connectivity()
        .checkConnectivity()
        .then((result) => result.toDomainEntity());
  }

  Stream<ConnectivityType> get statusStream {
    return Connectivity()
        .onConnectivityChanged
        .map((result) => result.toDomainEntity());
  }
}

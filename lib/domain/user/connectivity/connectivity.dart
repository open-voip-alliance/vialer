import 'package:connectivity_plus/connectivity_plus.dart';

import 'connectivity_type.dart';

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

extension ConnectivityTypeMapper on ConnectivityResult {
  ConnectivityType toDomainEntity() {
    switch (this) {
      case ConnectivityResult.mobile:
        return ConnectivityType.mobile;
      case ConnectivityResult.wifi:
        return ConnectivityType.wifi;
      default:
        return ConnectivityType.none;
    }
  }
}

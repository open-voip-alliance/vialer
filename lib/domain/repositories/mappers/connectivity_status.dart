import 'package:connectivity/connectivity.dart';

import '../../connectivity_status.dart';

extension ConnectivityStatusMapper on ConnectivityResult {
  ConnectivityStatus toDomainEntity() {
    switch (this) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
        return ConnectivityStatus.connected;
      case ConnectivityResult.none:
      default:
        return ConnectivityStatus.disconnected;
    }
  }
}

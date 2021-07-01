import 'package:connectivity_plus/connectivity_plus.dart';

import '../../connectivity_type.dart';

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

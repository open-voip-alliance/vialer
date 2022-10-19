enum ConnectivityType {
  mobile,
  wifi,
  none,
}

extension ConnectivityStatus on ConnectivityType {
  bool get isConnected => this != ConnectivityType.none;
}

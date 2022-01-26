enum Permission {
  phone,
  contacts,
  microphone,

  /// This is the BLUETOOTH_CONNECT permission, it only exists on Android 12
  /// and higher. We can route calls without it but the user won't have the
  /// complete experience (e.g. unable to choose which Bluetooth device to route
  /// to).
  ///
  /// Android only.
  bluetooth,
}

extension PermissionString on Permission {
  String toShortString() => toString().split('.')[1];
}

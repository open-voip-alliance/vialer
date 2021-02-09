enum Permission {
  phone,
  contacts,
  microphone,
}

extension PermissionString on Permission {
  String toShortString() => toString().split('.')[1];
}

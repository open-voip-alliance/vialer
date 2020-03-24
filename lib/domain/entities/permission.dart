enum Permission {
  phone,
  contacts,
}

extension PermissionString on Permission {
  String toShortString() => toString().split('.')[1];
}

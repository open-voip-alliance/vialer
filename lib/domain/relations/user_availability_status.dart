/// Represents the Logged In User's availability status. This is similar to
/// ColleagueAvailabilityStatus and sometimes derived from the same source
/// but there are different statuses available for each.
enum UserAvailabilityStatus {
  online,
  offline,
  doNotDisturb,
  onlineWithRingingDeviceOffline,
}

extension Basic on UserAvailabilityStatus {
  /// Converts any "complex" statuses into the basic status. For example,
  /// being [UserAvailabilityStatus.onlineWithRingingDeviceOffline] just
  /// becomes [UserAvailabilityStatus.online].
  ///
  /// Generally this is useful to convert a status that can display additional
  /// information to the user, to one that can actually be chosen.
  UserAvailabilityStatus get basic => switch (this) {
        UserAvailabilityStatus.onlineWithRingingDeviceOffline =>
          UserAvailabilityStatus.online,
        _ => this,
      };
}

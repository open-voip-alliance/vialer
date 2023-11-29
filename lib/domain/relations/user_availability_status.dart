/// Represents the Logged In User's availability status. This is similar to
/// ColleagueAvailabilityStatus and sometimes derived from the same source
/// but there are different statuses available for each.
enum UserAvailabilityStatus {
  online,
  offline,
  doNotDisturb;

  static String serializeToJson(UserAvailabilityStatus destination) =>
      destination.name;

  static UserAvailabilityStatus fromJson(dynamic json) =>
      UserAvailabilityStatus.values.byName(json as String);
}

/// Enumeration of feature flags. To test whether a certain feature
/// is enabled, use the [HasFeature] use case:
/// ```dart
/// if (_hasFeature(Feature.colleagueList)) {
///   // ...
/// }
/// ```
///
/// Features are enabled in the .env file. For example, `Feature.colleagueList`
/// would have the following entry in the .env if it's enabled:
/// ```dotenv
/// FEATURE_COLLEAGUE_LIST=true
/// ```
/// Any non-empty value is considered enabling the feature.
///
/// If a feature is no longer used, or if the feature is fully integrated
/// into the app, all the relevant if-checks should be removed, as well as
/// the enum and .env entries. If only one enum entry remains, mark it
/// [deprecated]. We can't remove it in that case, because
/// an enum always needs at least one constant.
enum Feature {
  @deprecated
  colleagueList,
}

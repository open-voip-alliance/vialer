import 'package:dartx/dartx.dart';

extension Prefix on String {
  /// Remove the prefix from a string if it is part of a longer string. e.g.
  /// '0123' should become '123' but '0' should not become ''.
  String removePrefixFromLonger(String characters) =>
      length > characters.length ? removePrefix(characters) : this;

  String formatForPhoneNumberQuery() => removePrefix('00').removePrefix('0');
}

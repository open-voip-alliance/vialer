import 'package:vialer/domain/use_case.dart';

class ValidateAccount extends UseCase {
  /// Validate if the password is valid according the VG format:
  /// at least 6 characters and 1 non-alphabetical character.
  static Future<bool> hasValidPasswordFormat(String password) {
    return Future.value(
        password.length >= 6 && RegExp('[^A-z]+').hasMatch(password));
  }

  /// Checks if the given [email] has a valid email format.
  ///
  /// The email format is validated using regular expressions. It checks if the email
  /// consists of a local part, a domain part, and a top-level domain (TLD) part.
  /// The local part can contain lowercase letters, numbers, and special characters
  /// like !#$%&'*+/=?^_`{|}~-.
  /// The domain part can contain lowercase letters, numbers, and hyphens (-).
  /// The TLD part can contain lowercase letters, numbers, and hyphens (-), and it
  /// must start with a period (.) followed by at least one character.
  ///
  /// Returns `true` if the [email] has a valid format, `false` otherwise.
  static Future<bool> hasValidEmailFormat(String email) {
    const local = r"[a-z0-9.!#$%&'*+/=?^_`{|}~-]+";
    const domain = '[a-z0-9](?:[a-z0-9-]{0,253}[a-z0-9])?';
    const tld = r'(?:\.[a-z0-9](?:[a-z0-9-]{0,253}[a-z0-9])?)+';
    final hasValidEmailFormat = RegExp(
      '^$local@$domain$tld\$',
      caseSensitive: false,
    ).hasMatch(email);
    return Future.value(hasValidEmailFormat);
  }
}

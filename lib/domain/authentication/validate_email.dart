import 'package:vialer/domain/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class ValidateEmail extends UseCase {
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
  Future<bool> call(String email) async {
    const local = r"[a-z0-9.!#$%&'*+/=?^_`{|}~-]+";
    const domain = '[a-z0-9](?:[a-z0-9-]{0,253}[a-z0-9])?';
    const tld = r'(?:\.[a-z0-9](?:[a-z0-9-]{0,253}[a-z0-9])?)+';
    return RegExp(
      '^$local@$domain$tld\$',
      caseSensitive: false,
    ).hasMatch(email);
  }
}

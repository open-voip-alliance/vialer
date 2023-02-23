import 'tests/main/settings/has_mobile_number.dart' as has_mobile_number;
import 'tests/onboarding/login/successful_login.dart' as successful_login;
import 'tests/onboarding/login/successful_login_with_no_app_account.dart' as successful_login_with_no_app_account;
import 'tests/onboarding/login/wrong_format.dart' as wrong_format;

/// This file exists to combine all tests into a single run when running on
/// an emulator. All new tests must be added to this.
main() {
  successful_login.main();
  successful_login_with_no_app_account.main();
  wrong_format.main();
  has_mobile_number.main();
}
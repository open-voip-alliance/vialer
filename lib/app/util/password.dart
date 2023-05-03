/// Validate if the password is valid according the VG format:
/// at least 6 characters and 1 non-alphabetical character.
bool hasValidPasswordFormat(String password) {
  return password.length >= 6 && RegExp('[^A-z]+').hasMatch(password);
}

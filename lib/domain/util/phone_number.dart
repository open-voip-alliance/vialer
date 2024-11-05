extension PhoneNumberUtils on String {
  bool looksLikePhoneNumber() => RegExp(r'^[0-9+() ]+$').hasMatch(this);

  bool get isInternalNumber =>
      length <= 10 && !startsWith('0') && !startsWith('+');
}

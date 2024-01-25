class UnableToInitializePhoneLibException extends ArgumentError {
  UnableToInitializePhoneLibException()
      : super(
          'Unable to initialize PhoneLib, there are no cached startup values',
        );
}

import 'vialer.dart';

class CallThroughException extends VialerException {}

class InvalidDestinationException extends CallThroughException {}

class NormalizationException extends CallThroughException {}

class NoMobileNumberException extends CallThroughException {}

class NumberTooLongException extends CallThroughException {}

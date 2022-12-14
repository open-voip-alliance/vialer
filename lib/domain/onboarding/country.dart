import 'package:equatable/equatable.dart';

class Country extends Equatable {
  final String name;

  /// Two-letter country code part of ISO 3166-1.
  final String isoCode;

  /// Country calling code.
  final String callingCode;

  const Country({
    required this.name,
    required this.isoCode,
    required this.callingCode,
  });

  /// Get the flag emoji based on the alpha-2 country code.
  String get flag => isoCode.toUpperCase().replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
      ); // https://stackoverflow.com/a/63961112

  @override
  List<Object?> get props => [name, isoCode, callingCode];

  @override
  String toString() => '$runtimeType('
      'name: $name, '
      'country code: $isoCode, '
      'calling code: $callingCode)';
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'country.freezed.dart';

@freezed
class Country with _$Country {
  const Country._();

  const factory Country({
    required String name,

    /// Two-letter country code part of ISO 3166-1.
    required String isoCode,

    /// Country calling code.
    required String callingCode,
  }) = _Country;

  /// Get the flag emoji based on the alpha-2 country code.
  String get flag => isoCode.toUpperCase().replaceAllMapped(
        RegExp('[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
      ); // https://stackoverflow.com/a/63961112
}

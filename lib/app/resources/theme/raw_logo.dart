// Never import anything from Flutter here!

import '../../../domain/entities/brand.dart';

class RawLogos {
  RawLogos._();

  static const vialer = 0xE98A;
  static const voys = 0xE975;
  static const verbonden = 0xE9AB;
  static const annabel = 0xE9AA;
}

extension BrandLogo on Brand {
  /// The logo code point in Vialer Sans.
  int get rawLogo {
    if (isVialer || isVialerStaging) {
      return RawLogos.vialer;
    } else if (isVoys || isVoysFreedom) {
      return RawLogos.voys;
    } else if (isVerbonden) {
      return RawLogos.verbonden;
    } else if (isAnnabel) {
      return RawLogos.annabel;
    } else {
      throw UnsupportedError('A logo must be added for $identifier');
    }
  }
}

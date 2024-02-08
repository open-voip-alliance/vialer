// Never import anything from Flutter here!

import '../../../data/models/user/brand.dart';

class BrandIconCodePoints {
  BrandIconCodePoints._();

  static const vialer = 0xE98A;
  static const voys = 0xE975;
  static const verbonden = 0xE9AB;
  static const annabel = 0xE9AA;
}

extension BrandIconCodePoint on Brand {
  /// The icon code point in Vialer Sans.
  int get iconCodePoint => select(
        vialer: BrandIconCodePoints.vialer,
        voys: BrandIconCodePoints.voys,
        verbonden: BrandIconCodePoints.verbonden,
        annabel: BrandIconCodePoints.annabel,
      );
}

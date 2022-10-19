import 'dart:convert';

import '../../brands.dart';
import 'brand.dart';

class BrandRepository {
  String? get currentBrandIdentifier => const bool.hasEnvironment('BRAND')
      ? const String.fromEnvironment('BRAND')
      : null;

  Iterable<Brand> getBrands() {
    final data = json.decode(brands) as List<dynamic>;

    return data.map((obj) => Brand.fromJson(obj as Map<String, dynamic>));
  }
}

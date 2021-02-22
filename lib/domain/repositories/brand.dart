import 'dart:convert';

import '../../brands.dart';
import '../entities/brand.dart';

class BrandRepository {
  String getCurrentBrandIdentifier() =>
      const String.fromEnvironment('BRAND', defaultValue: null);

  Iterable<Brand> getBrands() {
    final data = json.decode(brands) as List<dynamic>;

    return data.map((object) {
      object = object as Map<String, dynamic>;

      return Brand(
        identifier: object['identifier'] as String,
        appName: object['appName'] as String,
        url: Uri.parse(object['url'] as String),
      );
    });
  }
}

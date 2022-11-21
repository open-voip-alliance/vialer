import '../../dependency_locator.dart';
import '../use_case.dart';
import 'brand.dart';
import 'brand_repository.dart';

class GetBrand extends UseCase {
  final _brandRepository = dependencyLocator<BrandRepository>();

  Brand call() {
    final brandId = _brandRepository.currentBrandIdentifier ?? 'vialer';
    final brands = _brandRepository.getBrands();

    return brands.singleWhere(
      (b) => b.identifier == brandId,
    );
  }
}

import '../../dependency_locator.dart';
import '../entities/brand.dart';
import '../repositories/brand.dart';
import '../use_case.dart';

class GetBrandUseCase extends UseCase {
  final _brandRepository = dependencyLocator<BrandRepository>();

  Brand call() {
    final brandId = _brandRepository.currentBrandIdentifier ?? 'vialer';
    final brands = _brandRepository.getBrands();

    return brands.singleWhere(
      (b) => b.identifier == brandId,
    );
  }
}

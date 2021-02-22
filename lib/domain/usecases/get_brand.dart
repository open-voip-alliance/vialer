import '../../dependency_locator.dart';
import '../entities/brand.dart';
import '../repositories/brand.dart';
import '../use_case.dart';

class GetBrandUseCase extends UseCase<Brand> {
  final _brandRepository = dependencyLocator<BrandRepository>();

  @override
  Brand call() {
    final brandId = _brandRepository.getCurrentBrandIdentifier() ?? 'vialer';
    final brands = _brandRepository.getBrands();

    return brands.singleWhere(
      (b) => b.identifier == brandId,
    );
  }
}

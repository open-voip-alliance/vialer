import '../use_case.dart';
import 'get_brand.dart';

class GetShowAboutUseCase extends UseCase {
  final _getBrand = GetBrandUseCase();

  Future<bool> call() async {
    final brand = await _getBrand();

    return brand.aboutUrl.toString().isNotEmpty;
  }
}

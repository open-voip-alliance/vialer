import '../use_case.dart';
import 'get_brand.dart';

class GetUnencryptedSipUrlUseCase extends UseCase {
  final _getBrand = GetBrandUseCase();

  String call() => _getBrand().unencryptedSipUrl.toString();
}

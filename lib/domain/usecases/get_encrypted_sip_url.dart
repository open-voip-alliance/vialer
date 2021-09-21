import '../use_case.dart';
import 'get_brand.dart';

class GetEncryptedSipUrlUseCase extends UseCase {
  final _getBrand = GetBrandUseCase();

  String call() => _getBrand().encryptedSipUrl.toString();
}

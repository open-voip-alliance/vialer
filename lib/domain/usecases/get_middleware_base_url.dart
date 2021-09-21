import '../use_case.dart';
import 'get_brand.dart';

class GetMiddlewareBaseUrlUseCase extends UseCase {
  final _getBrand = GetBrandUseCase();

  String call() => _getBrand().middlewareUrl.toString();
}

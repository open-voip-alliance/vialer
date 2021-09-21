import '../use_case.dart';
import 'get_brand.dart';

class GetVoipgridBaseUrlUseCase extends UseCase {
  final _getBrand = GetBrandUseCase();

  String call() => _getBrand().voipgridUrl.toString();
}

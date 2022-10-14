import '../../dependency_locator.dart';
import '../use_case.dart';
import 'country.dart';
import 'country_repository.dart';

class GetCountriesUseCase extends UseCase {
  final _countryRepository = dependencyLocator<CountryRepository>();

  Future<Iterable<Country>> call() => _countryRepository.getCountries();
}

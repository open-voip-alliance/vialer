import '../../dependency_locator.dart';
import '../entities/country.dart';
import '../repositories/country.dart';
import '../use_case.dart';

class GetCountriesUseCase extends UseCase {
  final _countryRepository = dependencyLocator<CountryRepository>();

  Future<Iterable<Country>> call() => _countryRepository.getCountries();
}

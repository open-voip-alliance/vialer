import '../../../data/models/onboarding/country.dart';
import '../../../data/repositories/onboarding/country_repository.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

class GetCountriesUseCase extends UseCase {
  final _countryRepository = dependencyLocator<CountryRepository>();

  Future<Iterable<Country>> call() => _countryRepository.getCountries();
}

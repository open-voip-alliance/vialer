import 'package:rxdart/rxdart.dart';
import '../../../dependency_locator.dart';
import '../../legacy/storage.dart';
import '../../use_case.dart';
import '../../user/get_brand.dart';
import '../../user/get_logged_in_user.dart';
import 'colleague.dart';
import 'colleagues_repository.dart';
import 'import_colleagues.dart';

class ReceiveColleagueAvailability extends UseCase {
  late final _importColleagues = ImportColleagues();
  late final _getUser = GetLoggedInUserUseCase();
  late final _storage = dependencyLocator<StorageRepository>();
  late final _colleagueRepository = dependencyLocator<ColleaguesRepository>();
  late final _brand = GetBrand();

  /// The frequency that we will write the latest user availability data to the
  /// cache.
  static const _cacheInterval = Duration(seconds: 15);

  /// Emits a stream of all colleagues with their latest availability. These
  /// is no set order so they should be sorted by the consumer.
  Stream<List<Colleague>> call() async* {
    var colleagues = _storage.colleagues;

    // We are first checking if our cache has colleagues, if it does we will
    // immediately broadcast the contents of the cache before awaiting further
    // updates.
    if (colleagues.isNotEmpty) {
      yield colleagues;
    } else {
      colleagues = await _importColleagues();
    }

    final stream = _colleagueRepository
        .startListeningForAvailability(
          user: _getUser(),
          brand: _brand(),
          colleagues: colleagues,
        )
        .asBroadcastStream()
        .debounceTime(const Duration(seconds: 1));

    _regularlyCacheColleagues(stream);

    await for (final colleagues in stream) {
      yield colleagues;
    }
  }

  void _regularlyCacheColleagues(Stream stream) {
    stream.debounceTime(_cacheInterval).listen((colleagues) {
      _storage.colleagues = colleagues as List<Colleague>;
    });
  }
}

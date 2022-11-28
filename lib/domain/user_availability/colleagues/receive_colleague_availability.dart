import '../../../dependency_locator.dart';
import '../../legacy/storage.dart';
import '../../use_case.dart';
import '../../user/get_brand.dart';
import '../../user/get_logged_in_user.dart';
import 'colleague.dart';
import 'colleagues_repository.dart';

class ReceiveColleagueAvailability extends UseCase {
  late final _getUser = GetLoggedInUserUseCase();
  late final _storage = dependencyLocator<StorageRepository>();
  late final _colleaguesRepository = dependencyLocator<ColleaguesRepository>();
  late final _brand = GetBrand();

  /// Emits a stream of all colleagues with their latest availability status
  /// included.
  ///
  /// There is no set order so they should be sorted by the consumer.
  ///
  /// Setting [forceRefresh] will force disconnect the WebSocket first, this
  /// means that the full availability of all users will be provided up-front
  /// reconnecting.
  Stream<List<Colleague>> call({bool forceRefresh = false}) async* {
    var colleagues = _storage.colleagues;

    // We are first checking if our cache has colleagues, if it does we will
    // immediately broadcast the contents of the cache before awaiting further
    // updates.
    if (colleagues.isNotEmpty) {
      yield colleagues;

      // If we already have values stored in the cache, we don't want to wait
      // to fetch them from the server, so instead we immediately return the
      // value from the cache and then make sure the colleague list is updated
      // for the web socket eventually.
      _refreshColleagueCache().then(
        _colleaguesRepository.updateColleagueList,
      );
    } else {
      colleagues = await _refreshColleagueCache();
    }

    if (forceRefresh) {
      await _colleaguesRepository.stopListeningForAvailability();
    }

    final stream = _colleaguesRepository.startListeningForAvailability(
      user: _getUser(),
      brand: _brand(),
      initialColleagues: colleagues,
    );

    await for (final colleagues in await stream) {
      yield colleagues;
    }
  }

  Future<List<Colleague>> _refreshColleagueCache() async {
    final colleagues = await _colleaguesRepository.getColleagues(_getUser());
    _storage.colleagues = colleagues;
    return colleagues;
  }
}

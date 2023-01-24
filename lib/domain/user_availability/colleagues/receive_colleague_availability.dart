import '../../../app/util/synchronized_task.dart';
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
  late final _getBrand = GetBrand();

  /// Emits a stream of all colleagues with their latest availability status
  /// included.
  ///
  /// There is no set order so they should be sorted by the consumer.
  ///
  /// Setting [forceFullAvailabilityRefresh] to true will disconnect the
  /// WebSocket first, this means that the full availability of all users will
  /// be provided up-front upon reconnecting.
  Stream<List<Colleague>> call({
    bool forceFullAvailabilityRefresh = false,
  }) async* {
    // If the WebSocket is already connected, we don't need to do anything as
    // the stream is already set-up.
    if (_colleaguesRepository.isWebSocketConnected) return;

    var cachedColleagues = _storage.colleagues;

    // We are first checking if our cache has colleagues, if it does we will
    // immediately broadcast the contents of the cache before fetching
    // the new list.
    if (cachedColleagues.isNotEmpty) {
      yield cachedColleagues;
    }

    final colleagues = await _refreshColleagueCache();

    if (forceFullAvailabilityRefresh) {
      await _colleaguesRepository.stopListeningForAvailability();
    }

    final stream = await _colleaguesRepository.startListeningForAvailability(
      user: _getUser(),
      brand: _getBrand(),
      initialColleagues: colleagues,
    );

    await for (final colleagues in await stream) {
      yield colleagues;
    }
  }

  Future<List<Colleague>> _refreshColleagueCache() async =>
      SynchronizedTask<List<Colleague>>.of(this).run(
        () async {
          final colleagues =
              await _colleaguesRepository.getColleagues(_getUser());
          _storage.colleagues = colleagues;
          return colleagues;
        },
      );
}

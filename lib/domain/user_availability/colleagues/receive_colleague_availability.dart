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
  Future<Stream<List<Colleague>>> call({
    bool forceFullAvailabilityRefresh = false,
  }) async {
    // If the WebSocket is already connected, we don't need to do anything as
    // the stream is already set-up.
    if (_colleaguesRepository.isWebSocketConnected) {
      yield* _colleaguesRepository.broadcastStream!;
      return;
    }

    final cachedColleagues = _storage.colleagues;

    // Check the cache for some colleagues, if we have colleagues in the cache
    // then we won't request them from the server.
    final colleagues = cachedColleagues.isEmpty || forceFullAvailabilityRefresh
        ? await _fetchColleagues()
        : cachedColleagues;

    if (forceFullAvailabilityRefresh) {
      await _colleaguesRepository.stopListeningForAvailability();
    }

    yield* _colleaguesRepository.startListeningForAvailability(
      user: _getUser(),
      brand: _getBrand(),
      initialColleagues: colleagues,
    );
  }

  Future<List<Colleague>> _fetchColleagues() async =>
      SynchronizedTask<List<Colleague>>.of(this).run(
        () async => _storage.colleagues =
            await _colleaguesRepository.getColleagues(_getUser()),
      );
}

import 'package:dartx/dartx.dart';
import 'package:vialer/app/util/loggable.dart';
import 'package:vialer/app/util/synchronized_task.dart';
import 'package:vialer/domain/relations/colleagues/fetch_colleagues_from_remote.dart';
import 'package:vialer/domain/relations/websocket/listeners/listener.dart';
import 'package:vialer/domain/relations/websocket/payloads/user_availability_changed.dart';
import 'package:vialer/domain/user/get_stored_user.dart';

import '../../colleagues/colleague.dart';
import '../../colleagues/get_cached_colleagues.dart';
import '../../colleagues/update_cached_colleagues.dart';
import '../../events/colleague_list_did_change.dart';
import '../payloads/payload.dart';

typedef ColleagueList = List<Colleague>;

class ColleagueUpdateHandler extends Listener<UserAvailabilityChangedPayload>
    with Loggable {
  late final _getCachedColleagues = GetCachedColleagues();
  late final _updateCachedColleagues = UpdateCachedColleagues();
  late final _fetchColleagues = FetchColleaguesFromRemote();

  List<Colleague> colleagues = [];

  @override
  bool shouldHandle(Payload payload) {
    if (payload is! UserAvailabilityChangedPayload) return false;

    return !payload.isAboutLoggedInUser;
  }

  @override
  Future<void> handle(
    UserAvailabilityChangedPayload payload, {
    bool attemptRefresh = true,
  }) async {
    if (colleagues.isEmpty) {
      colleagues.addAnyNewColleagues(await _getCachedColleagues());
    }

    final colleague = colleagues.findByUserUuid(payload.userUuid);

    if (colleague == null) {
      if (!attemptRefresh) return;

      if (colleagues.isNotEmpty) {
        logger.info(
          'Received [UserAvailabilityChangedPayload] about a colleague '
          '[${payload.userUuid}] we have not retrieved from the API, this '
          'likely means they have been added recently. Attempting to fetch '
          'colleagues from remote to find them.',
        );
      }

      await _refreshColleagues();

      return handle(payload, attemptRefresh: false);
    }

    colleagues.replace(
      original: colleague,
      replacement: colleague.populateWithAvailability(payload),
    );

    _updateCachedColleagues(colleagues);

    broadcast(ColleagueListDidChangeEvent(colleagues));
  }

  Future<void> _refreshColleagues() async {
    this.colleagues = await _fetchColleaguesAsSyncTask();
    this.colleagues.addAnyNewColleagues(colleagues);
    this.colleagues.removeAnyDeletedColleagues(colleagues);
    this.colleagues.updateColleagueNameIfModified(colleagues);
  }

  Future<List<Colleague>> _fetchColleaguesAsSyncTask() =>
      SynchronizedTask<List<Colleague>>.of(this).run(() => _fetchColleagues());

  @override
  Future<void> onRefreshRequested() async {
    colleagues = [];
    return _refreshColleagues();
  }
}

extension on Colleague {
  Colleague populateWithAvailability(
    UserAvailabilityChangedPayload availability,
  ) =>
      map(
        (colleague) => colleague.copyWith(
          status: availability.availability,
          destination: ColleagueDestination(
            number: availability.internalNumber.toString(),
            type: availability.destinationType,
          ),
          context: availability.context,
        ),
        // We don't get availability updates for voip accounts so we will
        // just leave them as is.
        unconnectedVoipAccount: (voipAccount) => voipAccount,
      );
}

extension on List<Colleague> {
  Colleague? findByUserUuid(String uuid) =>
      where((colleague) => colleague.id == uuid).firstOrNull;

  void replace({required Colleague original, required Colleague replacement}) {
    final index = indexOf(original);

    replaceRange(
      index,
      index + 1,
      [replacement],
    );
  }

  /// We do not want to override any data from the websocket when new colleague
  /// information is fetched.
  ///
  /// This will only override the basic information and add new colleagues.
  void addAnyNewColleagues(List<Colleague> newColleagues) => addAll(
        newColleagues.where(
          (colleague) => findByUserUuid(colleague.id) == null,
        ),
      );

  void removeAnyDeletedColleagues(List<Colleague> newColleagues) {
    for (final colleague in this) {
      if (newColleagues.findByUserUuid(colleague.id) == null) {
        remove(colleague);
      }
    }
  }

  void updateColleagueNameIfModified(List<Colleague> newColleagues) {
    for (final colleague in this) {
      final latest = newColleagues.findByUserUuid(colleague.id);

      if (latest == null) continue;

      this.remove(colleague);
      this.add(colleague.copyWith(name: latest.name));
    }
  }
}

extension IsAboutLoggedInUser on UserAvailabilityChangedPayload {
  bool get isAboutLoggedInUser {
    final user = GetStoredUserUseCase()();

    return user != null ? user.uuid == userUuid : true;
  }
}

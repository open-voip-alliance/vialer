import 'package:injectable/injectable.dart';

import '../../../../dependency_locator.dart';
import '../../../../presentation/util/automatic_retry.dart';
import '../../../../presentation/util/loggable.dart';
import '../../../API/voipgrid/voipgrid_service.dart';
import '../../../models/calling/voip/destination.dart';
import '../../legacy/storage.dart';

@lazySingleton
class DestinationRepository with Loggable {
  DestinationRepository(this._service);

  final _storageRepository = dependencyLocator<StorageRepository>();

  final VoipgridService _service;
  final automaticRetry = AutomaticRetry.http('Change Destination');

  /// This is not a reference to a specific destination, but it is a reference
  /// to the object against the user that contains a selected destination. When
  /// we want to update the user's selected destination, we need to know this id
  /// even though it (at least seems to be) constant for each user.
  ///
  /// This is not useful data or impacts the user in anyway, it is purely to
  /// allow us to execute API requests.
  ///
  /// However, this means that this *needs* to be set whenever we get an API
  /// response that contains it, otherwise it won't be possible to set the
  /// destination.
  late int selectedUserDestinationId;

  Future<void> updateDestinations(Iterable<Destination> destinations) async {
    final staleDestinations = _storageRepository.availableDestinations;

    _storageRepository.availableDestinations =
        destinations.importIsOnline(staleDestinations).toList();
  }

  List<Destination> get availableDestinations =>
      _storageRepository.availableDestinations;

  Future<void> updateIsOnline(int accountId, bool isOnline) async =>
      _storageRepository.availableDestinations = _storageRepository
          .availableDestinations
          .updateIsOnline(accountId, isOnline)
          .toList();

  Future<bool> setDestination(Destination destination) async {
    final response = await _service.setAvailability(
      selectedUserDestinationId.toString(),
      destination.toPostParameters(),
    );

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Set destination');
      return false;
    }

    return true;
  }
}

extension on Destination {
  Map<String, dynamic> toPostParameters() => switch (this) {
        PhoneAccount dest => {'phoneaccount': dest.identifier.toString()},
        PhoneNumber dest => {'fixeddestination': dest.identifier.toString()},
        _ => {},
      };
}

extension on Iterable<Destination> {
  Iterable<Destination> updateIsOnline(int accountId, bool isOnline) => map(
        (destination) => destination.map(
          unknown: (destination) => destination,
          notAvailable: (destination) => destination,
          phoneNumber: (destination) => destination,
          phoneAccount: (destination) => destination.accountId == accountId
              ? destination.copyWith(isOnline: isOnline)
              : destination,
        ),
      );

  Iterable<Destination> importIsOnline(
    Iterable<Destination> staleDestinations,
  ) =>
      map((destination) {
        if (destination is PhoneAccount) {
          final staleDestination = staleDestinations
              .whereType<PhoneAccount>()
              .where((element) => element.accountId == destination.accountId)
              .firstOrNull;

          if (staleDestination != null) {
            return destination.copyWith(isOnline: staleDestination.isOnline);
          }
        }

        return destination;
      }).toList();
}

extension intToDestination on int {
  Destination asDestination() {
    late final storageRepository = dependencyLocator<StorageRepository>();
    final id = this;

    if (id == Destination.notAvailable().identifier) {
      return Destination.notAvailable();
    } else if (id == Destination.unknown().identifier) {
      return Destination.unknown();
    }

    return storageRepository.availableDestinations
        .firstWhere((destination) => id == destination.identifier);
  }
}

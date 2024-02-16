import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/settings/widgets/availability/ringing_device/widget.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../../data/models/calling/voip/destination.dart';
import '../../../../../../../data/models/user/user.dart';
import '../../../../../shared/widgets/loading_spinner_dropdown.dart';
import '../../../../../shared/widgets/stylized_dropdown.dart';

class MultipleRingingDeviceDropdown extends StatelessWidget {
  const MultipleRingingDeviceDropdown({
    required this.user,
    required this.destinations,
    required this.enabled,
    required this.loading,
    required this.onDestinationChanged,
    super.key,
  });

  final User user;
  final List<Destination> destinations;
  final bool enabled;
  final bool loading;
  final DestinationChangedCallback onDestinationChanged;

  /// Only destinations that match the [User]'s ringingDevice.
  List<Destination> get _relevantDestinations {
    final webphone = destinations.findWebphoneAccountFor(user: user);
    final appAccount = destinations.findAppAccountFor(user: user);

    switch (user.ringingDevice) {
      case RingingDeviceType.webphone:
        return webphone != null ? [webphone] : [];
      case RingingDeviceType.deskPhone:
        return destinations.deskPhonesFor(user: user);
      case RingingDeviceType.mobile:
        return appAccount != null ? [appAccount] : [];
      case RingingDeviceType.unknown:
      case RingingDeviceType.fixed:
        return destinations.fixedDestinationsFor(user: user);
    }
  }

  bool get _shouldShowDestinations => user.currentDestination is! NotAvailable;

  /// Currently we support a [NotAvailable] destination which won't appear in
  /// this list, so we only want to use the current destination if it is a
  /// phone account or a phone number.
  Destination? get _currentDestination =>
      user.currentDestination is PhoneAccount ||
              user.currentDestination is PhoneNumber
          ? user.currentDestination.toDestinationObject()
          : null;

  _MultipleRingingDeviceVisibility get _visibility {
    if (loading) return _MultipleRingingDeviceVisibility.loading;

    if (!_shouldShowDestinations) {
      return _MultipleRingingDeviceVisibility.offline;
    }

    return _MultipleRingingDeviceVisibility.visible;
  }

  @override
  Widget build(BuildContext context) {
    final relevantDestinations = _relevantDestinations;

    return Visibility(
      visible: relevantDestinations.isNotEmpty,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: switch (_visibility) {
          _MultipleRingingDeviceVisibility.loading => _LoadingDropdown(),
          _MultipleRingingDeviceVisibility.offline => _OfflineDropdown(),
          _MultipleRingingDeviceVisibility.visible => _DestinationDropdown(
              currentDestination: _currentDestination,
              relevantDestinations: relevantDestinations,
              enabled: enabled,
              onDestinationChanged: onDestinationChanged,
            ),
        },
      ),
    );
  }
}

class _DestinationDropdown extends StatelessWidget {
  const _DestinationDropdown({
    required Destination? this.currentDestination,
    required this.relevantDestinations,
    required this.enabled,
    required this.onDestinationChanged,
  });

  final Destination? currentDestination;
  final List<Destination> relevantDestinations;
  final bool enabled;
  final DestinationChangedCallback onDestinationChanged;

  @override
  Widget build(BuildContext context) {
    return StylizedDropdown<Destination>(
      value: (currentDestination ?? relevantDestinations.firstOrNull)
          ?.toDestinationObject(),
      items: relevantDestinations
          .map(
            (destination) => DropdownMenuItem<Destination>(
              value: destination.toDestinationObject(),
              child: _DestinationDropdownItem(destination),
              enabled: destination.isOnline,
            ),
          )
          .toList(),
      isExpanded: true,
      showIcon: relevantDestinations.length >= 2,
      onChanged: enabled && relevantDestinations.length >= 2
          ? (destination) => destination != null && destination.isOnline
              ? onDestinationChanged(destination)
              : () {}
          : null,
    );
  }
}

enum _MultipleRingingDeviceVisibility {
  loading,
  offline,
  visible,
}

class _DestinationDropdownItem extends StatelessWidget {
  const _DestinationDropdownItem(this.destination);

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: destination.isOnline ? 1 : 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (!destination.isOnline)
            Container(
              width: 28,
              child: FaIcon(
                FontAwesomeIcons.solidTriangleExclamation,
                size: 16,
                color: context.brand.theme.colors.red1,
              ),
            ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              destination.dropdownValue(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDropdown extends StatelessWidget {
  const _LoadingDropdown();

  @override
  Widget build(BuildContext context) {
    return LoadingSpinnerDropdown(
      color: context.brand.theme.colors.userAvailabilityUnknownAccent,
    );
  }
}

class _OfflineDropdown extends StatelessWidget {
  const _OfflineDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StylizedDropdown<bool>(
      value: true,
      items: [
        DropdownMenuItem<bool>(
          value: true,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(context.msg.ua.mobile.ringingDevice.dropdown.offline),
          ),
        ),
      ],
      isExpanded: true,
      showIcon: false,
      onChanged: null,
    );
  }
}

extension DestinationDropdown on Destination {
  String dropdownValue(BuildContext context) {
    final destination = this;

    return destination.when(
      unknown: () => context.msg.main.settings.list.calling.unknown,
      notAvailable: () => context.msg.main.settings.list.calling.notAvailable,
      phoneNumber: (_, description, phoneNumber) =>
          phoneNumber == null ? '$description' : '$phoneNumber / $description',
      phoneAccount: (_, description, __, internalNumber, isOnline) =>
          '$internalNumber / $description',
    );
  }
}

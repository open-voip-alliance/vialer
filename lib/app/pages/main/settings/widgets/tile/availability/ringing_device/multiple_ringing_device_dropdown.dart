import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vialer/app/pages/main/settings/widgets/tile/availability/ringing_device/widget.dart';
import '../../../../../../../../domain/calling/voip/destination.dart';
import '../../../../../../../../domain/user/user.dart';
import '../../../../../../../widgets/stylized_dropdown.dart';
import '../../availability.dart';

class MultipleRingingDeviceDropdown extends StatelessWidget {
  const MultipleRingingDeviceDropdown({
    required this.user,
    required this.destinations,
    required this.enabled,
    required this.onDestinationChanged,
    super.key,
  });

  final User user;
  final List<Destination> destinations;
  final bool enabled;
  final DestinationChangedCallback onDestinationChanged;

  /// Only destinations that match the [User]'s ringingDevice.
  List<Destination> get _relevantDestinations =>
      user.ringingDevice == RingingDeviceType.fixed
          ? destinations.fixedDestinationsFor(user: user)
          : destinations.deskPhonesFor(user: user);

  /// Currently we support a [NotAvailable] destination which won't appear in
  /// this list, so we only want to use the current destination if it is a
  /// phone account or a phone number.
  Destination? get _currentDestination =>
      user.currentDestination is PhoneAccount ||
              user.currentDestination is PhoneNumber
          ? user.currentDestination
          : null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: StylizedDropdown<Destination>(
        value: _currentDestination ?? _relevantDestinations.firstOrNull,
        items: _relevantDestinations
            .map(
              (destination) => DropdownMenuItem<Destination>(
                value: destination,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(destination.dropdownValue(context)),
                ),
              ),
            )
            .toList(),
        isExpanded: true,
        onChanged: enabled
            ? (destination) =>
                destination != null ? onDestinationChanged(destination) : () {}
            : null,
      ),
    );
  }
}

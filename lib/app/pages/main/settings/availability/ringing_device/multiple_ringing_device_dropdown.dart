import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vialer/app/pages/main/settings/availability/ringing_device/widget.dart';
import 'package:vialer/app/resources/localizations.dart';
import '../../../../../../../../domain/calling/voip/destination.dart';
import '../../../../../../../../domain/user/user.dart';
import '../../../../../widgets/stylized_dropdown.dart';
import '../../../widgets/loading_spinner_dropdown.dart';
import '../../../../../resources/theme.dart';

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
          ? user.currentDestination
          : null;

  @override
  Widget build(BuildContext context) {
    final relevantDestinations = _relevantDestinations;

    return Visibility(
      visible: relevantDestinations.isNotEmpty,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: !loading
            ? (_shouldShowDestinations
                ? StylizedDropdown<Destination>(
                    value:
                        _currentDestination ?? relevantDestinations.firstOrNull,
                    items: relevantDestinations
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
                    showIcon: relevantDestinations.length >= 2,
                    onChanged: enabled && _relevantDestinations.length >= 2
                        ? (destination) => destination != null
                            ? onDestinationChanged(destination)
                            : () {}
                        : null,
                  )
                : _OfflineDropdown())
            : _LoadingDropdown(),
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
      phoneAccount: (_, description, __, internalNumber) =>
          '$internalNumber / $description',
    );
  }
}

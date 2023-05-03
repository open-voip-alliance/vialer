import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../../../domain/calling/voip/destination.dart';
import '../../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../../domain/user/user.dart';
import 'button.dart';
import 'header.dart';

typedef DestinationChangedCallback = void Function(Destination destination);

class RingingDevice extends StatelessWidget {
  const RingingDevice({
    required this.user,
    required this.destinations,
    required this.onDestinationChanged,
    this.enabled = true,
    super.key,
  });

  final User user;
  final List<Destination> destinations;
  final DestinationChangedCallback onDestinationChanged;
  final bool enabled;

  Iterable<PhoneAccount> get _deskPhones => (destinations.toList(growable: true)
        ..remove(destinations.findAppAccountFor(user: user))
        ..remove(destinations.findWebphoneAccountFor(user: user)))
      .whereType<PhoneAccount>();

  Iterable<PhoneNumber> get _fixedDestinations => (destinations.toList(growable: true)
    ..remove(destinations.findAppAccountFor(user: user))
    ..remove(destinations.findWebphoneAccountFor(user: user)))
      .whereType<PhoneNumber>();

  bool get _shouldShowDestinationSelector {
    if ([
      RingingDeviceType.webphone,
      RingingDeviceType.mobile,
    ].contains(user.ringingDevice)) return false;

    if (user.ringingDevice == RingingDeviceType.fixed) {
      return _fixedDestinations.length >= 2;
    }

    if (user.ringingDevice == RingingDeviceType.deskPhone) {
      return _deskPhones.length >= 2;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ringingDevice = user.ringingDevice;
    final appAccount = destinations.findAppAccountFor(user: user);
    final webphoneAccount = destinations.findWebphoneAccountFor(user: user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AvailabilityHeader('Select your ringing device'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 3.5,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          children: [
            if (webphoneAccount != null)
              AvailabilityButton(
                text: 'Webphone',
                leadingIcon: FontAwesomeIcons.desktop,
                trailingIcon: ringingDevice == RingingDeviceType.webphone
                    ? FontAwesomeIcons.solidBellOn
                    : null,
                isActive: ringingDevice == RingingDeviceType.webphone,
                onPressed: () => onDestinationChanged(webphoneAccount),
              ),
            AvailabilityButton(
              text: 'Desk phone',
              leadingIcon: FontAwesomeIcons.phoneOffice,
              trailingIcon: ringingDevice == RingingDeviceType.deskPhone
                  ? FontAwesomeIcons.solidBellOn
                  : null,
              isActive: ringingDevice == RingingDeviceType.deskPhone,
              onPressed: () => onDestinationChanged(_deskPhones.first),
            ),
            if (appAccount != null)
              AvailabilityButton(
                text: 'Mobile',
                leadingIcon: FontAwesomeIcons.mobileNotch,
                trailingIcon: ringingDevice == RingingDeviceType.mobile
                    ? FontAwesomeIcons.solidBellOn
                    : null,
                isActive: ringingDevice == RingingDeviceType.mobile,
                onPressed: () => onDestinationChanged(appAccount),
              ),
            AvailabilityButton(
              text: 'Fixed destination',
              leadingIcon: FontAwesomeIcons.phoneArrowRight,
              trailingIcon: ringingDevice == RingingDeviceType.fixed
                  ? FontAwesomeIcons.solidBellOn
                  : null,
              onPressed: () => onDestinationChanged(_fixedDestinations.first),
              isActive: ringingDevice == RingingDeviceType.fixed,
            ),
          ],
        ),
        if (_shouldShowDestinationSelector) Text('Show')
      ],
    );
  }
}

extension on User {
  RingingDeviceType get ringingDevice {
    return settings.get(CallSetting.destination).map(
          unknown: (_) => RingingDeviceType.unknown,
          notAvailable: (_) => RingingDeviceType.unknown,
          phoneNumber: (_) => RingingDeviceType.fixed,
          phoneAccount: (phoneAccount) {
            if (phoneAccount.id.toString() == appAccountId) {
              return RingingDeviceType.mobile;
            }
            if (phoneAccount.id.toString() == webphoneAccountId) {
              return RingingDeviceType.webphone;
            }
            return RingingDeviceType.deskPhone;
          },
        );
  }
}

enum RingingDeviceType {
  unknown,
  webphone,
  deskPhone,
  mobile,
  fixed,
}

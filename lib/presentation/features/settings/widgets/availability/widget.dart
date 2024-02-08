import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/data/models/calling/voip/destination.dart';
import 'package:vialer/presentation/features/settings/widgets/availability/ringing_device/widget.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../data/models/user/settings/call_setting.dart';
import '../../../../shared/controllers/user_availability_status_builder/cubit.dart';
import '../../../../shared/widgets/user_availability_status_builder/widget.dart';
import '../../controllers/cubit.dart';
import '../tile/value.dart';
import '../tile/widget.dart';
import 'availability_status/widget.dart';

class AvailabilitySwitcher extends StatelessWidget {
  const AvailabilitySwitcher({super.key});

  void _showSnackBar(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(_buildSnackBar(context));

  void _hideSnackBar(BuildContext context) =>
      ScaffoldMessenger.of(context).clearSnackBars();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (_, state) {
        return UserAvailabilityStatusBuilder(
          listener: (context, status, isRingingDeviceOffline) =>
              isRingingDeviceOffline
                  ? _showSnackBar(context)
                  : _hideSnackBar(context),
          builder: (context, status, isRingingDeviceOffline) {
            return SettingTile(
              padding: EdgeInsets.zero,
              mergeSemantics: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AvailabilityStatusPicker(
                      onStatusChanged: (status) async => context
                          .read<UserAvailabilityStatusCubit>()
                          .changeAvailabilityStatus(
                            status,
                            state.availableDestinations,
                          ),
                      user: state.user,
                      enabled: state.shouldAllowRemoteSettings,
                      userAvailabilityStatus: status,
                      isRingingDeviceOffline: isRingingDeviceOffline,
                    ),
                  ),
                  if (state.availableDestinations.length >= 1)
                    RingingDevice(
                      user: state.user,
                      destinations: state.availableDestinations,
                      onDestinationChanged: (destination) async =>
                          defaultOnSettingChanged(
                        context,
                        CallSetting.destination,
                        destination.identifier,
                      ),
                      enabled: state.shouldAllowRemoteSettings,
                      userAvailabilityStatus: status,
                      isRingingDeviceOffline: isRingingDeviceOffline,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

SnackBar _buildSnackBar(BuildContext context) {
  return SnackBar(
    content: Row(
      children: [
        FaIcon(
          FontAwesomeIcons.triangleExclamation,
          color: context.brand.theme.colors.userAvailabilityBusyAccent,
        ),
        SizedBox(
          width: 20,
        ),
        Flexible(
          child: Text(
            context.msg.main.colleagues.status.selectedDeviceOffline,
            style: TextStyle(
              color: context.brand.theme.colors.userAvailabilityBusyAccent,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: context.brand.theme.colors.userAvailabilityBusy,
    duration: Duration(days: 365),
  );
}

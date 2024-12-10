import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../data/models/user/events/logged_in_user_availability_changed.dart';
import '../../../../../../data/models/user/user.dart';
import '../../../../shared/widgets/bottom_navigation_profile_icon.dart';
import '../../../../util/event_bus_listener.dart';

class Header extends StatefulWidget {
  const Header({
    required this.user,
    super.key,
  });

  final User user;

  @override
  State<StatefulWidget> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  String? _internalNumber;

  String get _subheading => _internalNumber.isNotNullOrBlank
      ? '$_internalNumber - ${widget.user.email}'
      : widget.user.email;

  @override
  Widget build(BuildContext context) {
    return EventBusListener<LoggedInUserAvailabilityChanged>(
      listener: (event) => setState(
        () => _internalNumber = event.availability.internalNumber.toString(),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        child: Row(
          children: [
            BottomNavigationProfileIcon(
              active: true,
              large: true,
              color: context.brand.theme.colors.grey4,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.user.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.brand.theme.colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    _subheading,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.brand.theme.colors.grey6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

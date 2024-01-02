import 'package:vialer/domain/relations/user_availability_status.dart';

import 'colleagues/colleague.dart';

extension ConvertAvailabilityStatus on ColleagueAvailabilityStatus {
  UserAvailabilityStatus toUserAvailabilityStatus() => switch (this) {
        ColleagueAvailabilityStatus.offline => UserAvailabilityStatus.offline,
        ColleagueAvailabilityStatus.availableForColleagues =>
          UserAvailabilityStatus.availableForColleagues,
        ColleagueAvailabilityStatus.doNotDisturb =>
          UserAvailabilityStatus.doNotDisturb,
        _ => UserAvailabilityStatus.online,
      };
}

import 'package:chopper/chopper.dart' hide JsonConverter;
import 'package:injectable/injectable.dart';

import '../../user/get_brand.dart';
import '../../util.dart';

part 'feature_announcements_service.chopper.dart';

@ChopperApi()
@injectable
abstract class FeatureAnnouncementsService extends ChopperService {
  @factoryMethod
  static FeatureAnnouncementsService create() {
    final brand = GetBrand()();
    final featureAnnouncementsUrl = brand.featureAnnouncementsUrl.toString();

    return _$FeatureAnnouncementsService(
      ChopperClient(
        baseUrl: Uri.parse(featureAnnouncementsUrl),
        converter: JsonConverter(),
        interceptors: <RequestInterceptor>[
          const AuthorizationInterceptor(
            onlyModernAuth: true,
          ),
        ],
      ),
    );
  }

  @Head(path: 'feature-announcements?interface=mobile')
  Future<Response<void>> getUnreadAnnouncements();
}

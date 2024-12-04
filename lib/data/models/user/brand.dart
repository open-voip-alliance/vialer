import 'package:freezed_annotation/freezed_annotation.dart';

part 'brand.freezed.dart';

part 'brand.g.dart';

@freezed
class Brand with _$Brand {
  const factory Brand({
    required String identifier,
    required String appId,
    required String appName,
    required Uri url,
    required Uri middlewareUrl,
    required Uri voipgridUrl,
    required Uri sipUrl,
    required Uri businessAvailabilityUrl,
    required Uri openingHoursBasicUrl,
    required Uri privacyPolicyUrl,
    required Uri? signUpUrl,
    required Uri availabilityServiceUrl,
    required Uri sharedContactsUrl,
    required Uri phoneNumberValidationUrl,
    required Uri featureAnnouncementsUrl,
    required Uri resgateUrl,
    required Uri? supportUrl,
  }) = _Brand;

  const Brand._();

  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);

  bool get isVialer => identifier == 'vialer';

  bool get isVialerStaging => identifier == 'vialerStaging';

  bool get isVoys => identifier == 'voys';

  bool get isVerbonden => identifier == 'verbonden';

  bool get isAnnabel => identifier == 'annabel';
}

extension GetBrandValue on Brand {
  /// Select and get a value depending on the current brand.
  ///
  /// Note: [vialer] is chosen when either [isVialer] or [isVialerStaging]
  /// is true.
  T select<T>({
    required T vialer,
    required T voys,
    required T verbonden,
    required T annabel,
  }) {
    if (isVialer || isVialerStaging) {
      return vialer;
    } else if (isVoys) {
      return voys;
    } else if (isVerbonden) {
      return verbonden;
    } else if (isAnnabel) {
      return annabel;
    } else {
      throw UnsupportedError('Unsupported brand: $identifier');
    }
  }

  bool get hasSupportUrl => supportUrl != null;
}

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'brand.g.dart';

@immutable
@JsonSerializable()
class Brand extends Equatable {
  final String identifier;
  final String appId;
  final String appName;
  final Uri url;
  final Uri middlewareUrl;
  final Uri voipgridUrl;
  final Uri encryptedSipUrl;
  final Uri unencryptedSipUrl;
  final Uri businessAvailabilityUrl;
  final Uri userAvailabilityWsUrl;
  final Uri privacyPolicyUrl;

  const Brand({
    required this.identifier,
    required this.appId,
    required this.appName,
    required this.url,
    required this.middlewareUrl,
    required this.voipgridUrl,
    required this.encryptedSipUrl,
    required this.unencryptedSipUrl,
    required this.businessAvailabilityUrl,
    required this.userAvailabilityWsUrl,
    required this.privacyPolicyUrl,
  });

  @override
  List<Object?> get props => [
        identifier,
        appId,
        appName,
        url,
        middlewareUrl,
        voipgridUrl,
        encryptedSipUrl,
        unencryptedSipUrl,
        businessAvailabilityUrl,
    userAvailabilityWsUrl,
        privacyPolicyUrl,
      ];

  bool get isVialer => identifier == 'vialer';

  bool get isVialerStaging => identifier == 'vialerStaging';

  bool get isVoys => identifier == 'voys';

  bool get isVerbonden => identifier == 'verbonden';

  bool get isAnnabel => identifier == 'annabel';

  static Brand fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);

  Map<String, dynamic> toJson() => _$BrandToJson(this);

  @override
  String toString() => '$runtimeType('
      'identifier: $identifier, '
      'appId: $appId, '
      'appName: $appName, '
      'url: $url, '
      'middlewareUrl: $middlewareUrl, '
      'voipgridUrl: $voipgridUrl, '
      'encryptedSipUrl: $encryptedSipUrl, '
      'unencryptedSipUrl: $unencryptedSipUrl, '
      'businessAvailabilityUrl: $businessAvailabilityUrl,'
      'userAvailabilityWsUrl: $userAvailabilityWsUrl)';
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
}

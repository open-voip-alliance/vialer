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

  const Brand({
    required this.identifier,
    required this.appId,
    required this.appName,
    required this.url,
    required this.middlewareUrl,
    required this.voipgridUrl,
    required this.encryptedSipUrl,
    required this.unencryptedSipUrl,
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
      'unencryptedSipUrl: $unencryptedSipUrl)';
}

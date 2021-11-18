import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Brand extends Equatable {
  final String identifier;
  final String appName;
  final Uri url;
  final Uri middlewareUrl;
  final Uri voipgridUrl;
  final Uri encryptedSipUrl;
  final Uri unencryptedSipUrl;

  const Brand({
    required this.identifier,
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

  bool get isVoysFreedom => identifier == 'voysFreedom';

  bool get isVerbonden => identifier == 'verbonden';

  bool get isAnnabel => identifier == 'annabel';

  @override
  String toString() => '$runtimeType('
      'identifier: $identifier, '
      'appName: $appName, '
      'url: $url, '
      'middlewareUrl: $middlewareUrl, '
      'voipgridUrl: $voipgridUrl, '
      'encryptedSipUrl: $encryptedSipUrl, '
      'unencryptedSipUrl: $unencryptedSipUrl)';
}

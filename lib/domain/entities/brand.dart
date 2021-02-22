import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Brand extends Equatable {
  final String identifier;
  final String appName;
  final Uri url;

  const Brand({
    @required this.identifier,
    @required this.appName,
    @required this.url,
  });

  @override
  List<Object> get props => [identifier, appName, url];

  bool get isVialer => identifier == 'vialer';

  bool get isVoys => identifier == 'voys';

  bool get isVoysFreedom => identifier == 'voysFreedom';

  @override
  String toString() =>
      '$runtimeType(identifier: $identifier, appName: $appName, url: $url)';
}

import 'package:chopper/chopper.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../app/util/loggable.dart';

part 'voipgrid_api_resource_collector.freezed.dart';
part 'voipgrid_api_resource_collector.g.dart';

typedef Requester = Future<Response> Function(int page);
typedef Deserializer<T> = T Function(Map<String, dynamic> json);

/// Allows for easy access to an entire resource, when this resource is
/// paginated.
///
/// This should only be used with APIs that return responses compatible with
/// [_PaginatedVoipgridApiResponse], this should be all APIs 2022-onwards.
class VoipgridApiResourceCollector with Loggable {
  /// This is to prevent situations where a developer is requesting a huge
  /// number of items causing a vast number of requests. This should only
  /// ever be set to [false] in specific situations where this is known
  /// and handled.
  final bool safe;

  /// An arbitrary limit for how many pages should be fetched for most normal
  /// operations that require fetching an entire resource.
  ///
  /// See [safe] for more information.
  static const _maxPagesToSafelyFetch = 20;

  VoipgridApiResourceCollector({
    this.safe = true,
  });

  /// Collect all items from a given resource on the VoIPGRID API. This will
  /// continually create more requests and return the resulting number
  /// of items.
  Future<List<T>> collect<T>({
    required Requester requester,
    required Deserializer<T> deserializer,
  }) async =>
      (await _makeRequest(requester))
          .map((item) => (item as Map<String, dynamic>))
          .map(deserializer)
          .toList();

  Stream<dynamic> _makeRequest(
    Requester requester, {
    int page = 1,
  }) async* {
    if (safe && page > _maxPagesToSafelyFetch) {
      logger.warning(
        'Attempting to fetch more pages '
        'than [$_maxPagesToSafelyFetch], set [safely] if this is intended.',
      );
      return;
    }

    final response = await requester(page);

    // We sometimes have to query subsequent pages to check if there are more
    // records. In this situation we don't want to log anything because it is
    // a valid scenario.
    if (response.statusCode == 404 && page != 1) return;

    if (!response.isSuccessful) {
      logger.warning(
        'Request failed with code: ${response.statusCode}',
      );
      return;
    }

    late final _PaginatedVoipgridApiResponse paginatedResponse;

    if (response.body is Map) {
      paginatedResponse = _PaginatedVoipgridApiResponse.fromJson(
        response.body as Map<String, dynamic>,
      );
    } else if (response.hasLinkHeader) {
      paginatedResponse = _PaginatedVoipgridApiResponse.known(
        items: response.body as List<dynamic>,
        hasMore: response.hasMoreInLinkHeader,
      );
    } else {
      // This will handle APIs that allow for this type of pagination, but
      // don't return an explicit next field. We have to query the next page
      // and see if a 404 is given.
      paginatedResponse = _PaginatedVoipgridApiResponse.ambiguous(
        items: response.body as List<dynamic>,
      );
    }

    for (final vc in paginatedResponse.items) {
      yield vc;
    }

    if (paginatedResponse.hasMore) {
      yield* _makeRequest(
        requester,
        page: ++page,
      );
    }
  }
}

@freezed
class _PaginatedVoipgridApiResponse with _$_PaginatedVoipgridApiResponse {
  const _PaginatedVoipgridApiResponse._();

  const factory _PaginatedVoipgridApiResponse({
    required String? next,
    required List<dynamic> items,
  }) = __PaginatedVoipgridApiResponse;

  factory _PaginatedVoipgridApiResponse.fromJson(Map<String, dynamic> json) =>
      _$_PaginatedVoipgridApiResponseFromJson(json);

  factory _PaginatedVoipgridApiResponse.known({
    required List<dynamic> items,
    required bool hasMore,
  }) =>
      _PaginatedVoipgridApiResponse(next: hasMore ? ' ' : null, items: items);

  factory _PaginatedVoipgridApiResponse.ambiguous({
    required List<dynamic> items,
  }) =>
      _PaginatedVoipgridApiResponse(next: ' ', items: items);

  bool get hasMore => next != null;
}

extension on Response {
  static const _linkHeader = 'link';

  bool get hasLinkHeader => headers.containsKey(_linkHeader);

  bool get hasMoreInLinkHeader =>
      headers[_linkHeader]?.contains('next') == true;
}

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

    if (!response.isSuccessful) {
      logger.warning(
        'Request failed with code: ${response.statusCode}',
      );
      return;
    }

    final paginatedResponse = _PaginatedVoipgridApiResponse.fromJson(
      response.body as Map<String, dynamic>,
    );

    for (final vc in paginatedResponse.items) {
      yield vc;
    }

    if (paginatedResponse.hasMore) {
      _makeRequest(
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

  bool get hasMore => next != null;
}

class PaginatedList<T> {
  const PaginatedList({
    required this.results,
    required this.count,
    this.next,
    this.previous,
  });

  final List<T> results;
  final int count;
  final String? next;
  final String? previous;

  bool get hasMore => next != null;
}

/// Unwraps either a DRF paginated response `{"count": N, "results": [...]}`
/// or a bare JSON array `[...]`.
PaginatedList<T> unwrapList<T>(
  dynamic data,
  T Function(dynamic json) fromJson,
) {
  if (data is List) {
    final items = data.map(fromJson).toList();
    return PaginatedList(
      results: items,
      count: items.length,
    );
  }

  if (data is Map<String, dynamic>) {
    final resultsRaw = data['results'] as List<dynamic>? ?? [];
    final items = resultsRaw.map(fromJson).toList();
    final count = (data['count'] as num?)?.toInt() ?? items.length;
    final next = data['next'] as String?;
    final previous = data['previous'] as String?;

    return PaginatedList(
      results: items,
      count: count,
      next: next,
      previous: previous,
    );
  }

  return PaginatedList<T>(results: [], count: 0);
}

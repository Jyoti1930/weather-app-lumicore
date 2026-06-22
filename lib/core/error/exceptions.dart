/// Exceptions thrown by data sources (remote/local). These are caught and
/// translated into [Failure]s by the repository layer.
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CityNotFoundException implements Exception {
  final String message;
  CityNotFoundException(this.message);
}

class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

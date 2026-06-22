/// Failures represent user-facing error states surfaced from the domain layer.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CityNotFoundFailure extends Failure {
  const CityNotFoundFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

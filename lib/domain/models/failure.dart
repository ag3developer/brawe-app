import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.network() = NetworkFailure;
  const factory Failure.server() = ServerFailure;
  const factory Failure.unauthorized() = UnauthorizedFailure;
  const factory Failure.validation([String? message]) = ValidationFailure;
  const factory Failure.unknown() = UnknownFailure;

  const Failure._();

  String toDisplayMessage() => when(
    network: () => 'No internet connection',
    server: () => 'Server error occurred',
    unauthorized: () => 'Invalid credentials',
    validation: (m) => m ?? 'Validation failed',
    unknown: () => 'An unexpected error occurred',
  );
}

import '../constants/app_strings.dart';

/// Base failure type for domain and presentation layers.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = AppStrings.errorCache]);
}

final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = AppStrings.errorValidation]);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = AppStrings.errorUnknown]);
}

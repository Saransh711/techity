import 'failure.dart';

/// Maps low-level exceptions to typed [Failure] instances.
abstract final class ErrorMapper {
  static Failure map(Object error) {
    return switch (error) {
      FormatException _ => const ValidationFailure(),
      ArgumentError _ => const ValidationFailure(),
      _ when _isHiveError(error) => CacheFailure(_hiveMessage(error)),
      _ => UnknownFailure(error.toString()),
    };
  }

  static bool _isHiveError(Object error) =>
      error.runtimeType.toString() == 'HiveError';

  static String _hiveMessage(Object error) {
    try {
      final message = (error as dynamic).message;
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } catch (_) {
      // Fall through to default cache message.
    }
    return 'Hive error';
  }
}

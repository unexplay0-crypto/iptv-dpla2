import 'package:logger/logger.dart';

/// Wrapper simples de logging. Nunca registra URLs com credenciais embutidas.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: false,
    ),
  );

  static void d(String message) => _logger.d(message);
  static void i(String message) => _logger.i(message);
  static void w(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.w(message, error: error, stackTrace: stackTrace);
  static void e(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  /// Remove usuario/senha/token de uma URL antes de logar.
  static String safeUrl(String url) {
    return url
        .replaceAll(RegExp(r'(username|user|u)=[^&]+', caseSensitive: false),
            r'username=***')
        .replaceAll(RegExp(r'(password|pass|p)=[^&]+', caseSensitive: false),
            r'password=***')
        .replaceAll(RegExp(r'(token|api_key|key)=[^&]+', caseSensitive: false),
            r'token=***');
  }
}

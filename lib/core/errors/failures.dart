abstract class AppFailure implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppFailure(this.message, {this.code, this.details});

  @override
  String toString() => 'AppFailure(code: $code, message: $message)';
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message, {super.code, super.details});
}

class AuthFailure extends AppFailure {
  const AuthFailure(super.message, {super.code, super.details});
}

class PermissionFailure extends AppFailure {
  const PermissionFailure(super.message, {super.code, super.details});
}

class AppNotFoundFailure extends AppFailure {
  final String packageName;
  const AppNotFoundFailure(
    super.message, {
    required this.packageName,
    super.code,
    super.details,
  });
}

class WebsiteGenerationFailure extends AppFailure {
  const WebsiteGenerationFailure(super.message, {super.code, super.details});
}

class SecurityViolationFailure extends AppFailure {
  const SecurityViolationFailure(super.message, {super.code, super.details});
}

class SpeechRecognitionFailure extends AppFailure {
  const SpeechRecognitionFailure(super.message, {super.code, super.details});
}

class PlatformFailure extends AppFailure {
  const PlatformFailure(super.message, {super.code, super.details});
}

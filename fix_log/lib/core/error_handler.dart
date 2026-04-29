import 'dart:io';
import 'app_exception.dart';

/// Converts any exception into a user-friendly Spanish message.
String friendlyError(Object error) {
  if (error is AppException) {
    final code = error.statusCode;
    if (code != null && code >= 500) return 'Error del servidor. Inténtalo más tarde.';
    return switch (code) {
      400 => error.message,
      401 => 'Sesión expirada. Inicia sesión de nuevo.',
      403 => 'No tienes permiso para esta acción.',
      _ => error.message,
    };
  }
  if (error is SocketException) {
    return 'Sin conexión. Verifica tu red e inténtalo de nuevo.';
  }
  return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
}

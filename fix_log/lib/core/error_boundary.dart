import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../ui/core/strings.dart';
import 'logger.dart';

/// Wires Flutter's global error hooks so the app never shows a blank/frozen
/// screen or crashes silently.
void setupErrorBoundary() {
  FlutterError.onError = (details) {
    appLogger.e(
      'Unhandled Flutter error',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    appLogger.e('Unhandled async error', error: error, stackTrace: stack);
    return true;
  };

  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const _FallbackErrorWidget();
  }
}

class _FallbackErrorWidget extends StatelessWidget {
  const _FallbackErrorWidget();

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            AppStrings.unexpectedErrorFallback,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

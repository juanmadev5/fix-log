import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final appLogger = Logger(
  printer: SimplePrinter(colors: false),
  level: kReleaseMode ? Level.warning : Level.debug,
);

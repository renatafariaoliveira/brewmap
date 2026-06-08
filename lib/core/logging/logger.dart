import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 100,
    colors: false,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  filter: _logFilter(),
);

LogFilter _logFilter() => kDebugMode ? DevelopmentFilter() : ProductionFilter();

String _formatMessage(String message, {Map<String, dynamic>? extras}) {
  if (extras == null || extras.isEmpty) return message;
  return '$message | extras=${jsonEncode(extras)}';
}

void logWarning(
  String message, {
  Map<String, dynamic>? extras,
  StackTrace? stackTrace,
}) {
  logger.w(_formatMessage(message, extras: extras), stackTrace: stackTrace);
}

void logInfo(String message, {Map<String, dynamic>? extras}) {
  logger.i(_formatMessage(message, extras: extras));
}

void logError(
  String message, {
  Map<String, dynamic>? extras,
  StackTrace? stackTrace,
}) {
  logger.e(_formatMessage(message, extras: extras), stackTrace: stackTrace);
}

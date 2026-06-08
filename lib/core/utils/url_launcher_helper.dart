import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds a launchable [Uri] from a user-provided [url] string.
///
/// Supported inputs:
/// - `tel:` URLs: keeps only digits (returns `null` if empty after sanitizing).
/// - URLs without a scheme: defaults to `https://`.
///
/// Returns `null` when [url] is blank or cannot be parsed into a valid [Uri].
Uri? _uriForLaunch(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;

  if (trimmed.startsWith('tel:')) {
    final digits = trimmed.substring(4).replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return Uri(scheme: 'tel', path: digits);
  }

  final withScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(trimmed)
      ? trimmed
      : 'https://$trimmed';
  return Uri.tryParse(withScheme);
}

/// Formats a phone string as US 10-digit display text.
///
/// Non-digit characters are stripped before formatting. If the resulting number
/// is not exactly 10 digits, returns [raw] unchanged.
String formatPhoneUS10(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) {
    return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
  }
  return raw;
}

/// Converts a URL into a compact display label.
///
/// Removes `http://` / `https://` and a single trailing `/` when present.
String displayWebsiteUrl(String url) {
  return url
      .replaceFirst(RegExp(r'^https?://'), '')
      .replaceFirst(RegExp(r'/$'), '');
}

/// Launches [url] using the platform external application handler.
///
/// Returns `false` if [url] cannot be converted to a [Uri] or if the platform
/// launch fails. When launch fails, shows a [SnackBar] (if [context] is still
/// mounted).
Future<bool> launchExternalUrl(BuildContext context, String url) async {
  final uri = _uriForLaunch(url);
  if (uri == null) return false;

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir o link.')),
    );
  }
  return launched;
}

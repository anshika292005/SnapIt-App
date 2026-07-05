// ignore_for_file: deprecated_member_use

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

import 'location_service.dart';

LocationService createPlatformLocationService() => _WebLocationService();

class _WebLocationService implements LocationService {
  @override
  Future<UserLocation> getCurrentLocation() async {
    if (html.window.isSecureContext != true) {
      throw StateError(
        'Browser location needs a secure origin. Open this app on localhost or HTTPS.',
      );
    }

    final position = await html.window.navigator.geolocation.getCurrentPosition(
      enableHighAccuracy: true,
      timeout: const Duration(seconds: 12),
    );
    final latitude = position.coords?.latitude?.toDouble();
    final longitude = position.coords?.longitude?.toDouble();

    if (latitude == null || longitude == null) {
      throw StateError('Unable to read your browser location.');
    }

    final areaLabel = await _reverseGeocode(latitude, longitude);

    return UserLocation(
      label: areaLabel ??
          'Live location - ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<String?> _reverseGeocode(double latitude, double longitude) async {
    try {
      final url = Uri.https(
        'api.bigdatacloud.net',
        '/data/reverse-geocode-client',
        {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'localityLanguage': 'en',
        },
      );
      final response = await html.HttpRequest.getString(url.toString());
      final data = jsonDecode(response) as Map<String, dynamic>;
      final locality = data['locality'] as String?;
      final city = data['city'] as String?;
      final principalSubdivision = data['principalSubdivision'] as String?;
      final country = data['countryName'] as String?;

      final parts = [
        if ((locality ?? '').trim().isNotEmpty) locality!.trim(),
        if ((city ?? '').trim().isNotEmpty && city != locality) city!.trim(),
        if ((principalSubdivision ?? '').trim().isNotEmpty)
          principalSubdivision!.trim(),
        if ((country ?? '').trim().isNotEmpty) country!.trim(),
      ];

      if (parts.isEmpty) {
        return null;
      }

      return 'Delivering to ${parts.take(3).join(', ')}';
    } catch (_) {
      return null;
    }
  }
}

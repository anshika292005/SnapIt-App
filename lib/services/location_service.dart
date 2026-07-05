import 'location_service_stub.dart'
    if (dart.library.html) 'location_service_web.dart';

class UserLocation {
  const UserLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  final String label;
  final double latitude;
  final double longitude;
}

abstract class LocationService {
  Future<UserLocation> getCurrentLocation();
}

LocationService createLocationService() => createPlatformLocationService();

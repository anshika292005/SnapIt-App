import 'location_service.dart';

LocationService createPlatformLocationService() =>
    _UnsupportedLocationService();

class _UnsupportedLocationService implements LocationService {
  @override
  Future<UserLocation> getCurrentLocation() {
    throw UnsupportedError('Location is available in the web browser preview.');
  }
}

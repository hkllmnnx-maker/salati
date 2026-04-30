import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_info.dart';

class LocationException implements Exception {
  final String message;
  LocationException(this.message);
  @override
  String toString() => message;
}

class LocationService {
  /// طلب صلاحية الموقع والحصول على الإحداثيات
  static Future<LocationInfo> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('خدمة الموقع غير مفعّلة على الجهاز.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('تم رفض إذن الموقع.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
          'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من الإعدادات.');
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 20),
      ),
    );

    String city = '';
    String country = '';
    try {
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude)
              .timeout(const Duration(seconds: 10));
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        city = p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? '';
        country = p.country ?? '';
      }
    } catch (_) {
      // فشل عكس الإحداثيات لا يمنعنا من حساب الصلاة
    }

    if (city.isEmpty) city = 'موقعك الحالي';
    if (country.isEmpty) country = '';

    return LocationInfo(
      latitude: pos.latitude,
      longitude: pos.longitude,
      country: country,
      city: city,
      isManual: false,
    );
  }

  static Future<bool> hasLocationPermission() async {
    final p = await Geolocator.checkPermission();
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }
}

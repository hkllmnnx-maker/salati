/// نموذج بيانات الموقع الجغرافي
class LocationInfo {
  final double latitude;
  final double longitude;
  final String country;
  final String city;
  final bool isManual;

  const LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.city,
    this.isManual = false,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'city': city,
        'isManual': isManual,
      };

  factory LocationInfo.fromJson(Map<String, dynamic> json) => LocationInfo(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        country: json['country'] as String? ?? '',
        city: json['city'] as String? ?? '',
        isManual: json['isManual'] as bool? ?? false,
      );

  LocationInfo copyWith({
    double? latitude,
    double? longitude,
    String? country,
    String? city,
    bool? isManual,
  }) =>
      LocationInfo(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        country: country ?? this.country,
        city: city ?? this.city,
        isManual: isManual ?? this.isManual,
      );
}

/// قاعدة بيانات مدن جاهزة (للاختيار اليدوي بدون GPS)
class City {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}

/// قائمة مدن عربية وعالمية شائعة
class Cities {
  static const List<City> list = [
    City(name: 'مكة المكرمة', country: 'السعودية', latitude: 21.4225, longitude: 39.8262),
    City(name: 'المدينة المنورة', country: 'السعودية', latitude: 24.4709, longitude: 39.6122),
    City(name: 'الرياض', country: 'السعودية', latitude: 24.7136, longitude: 46.6753),
    City(name: 'جدة', country: 'السعودية', latitude: 21.4858, longitude: 39.1925),
    City(name: 'الدمام', country: 'السعودية', latitude: 26.4207, longitude: 50.0888),
    City(name: 'القاهرة', country: 'مصر', latitude: 30.0444, longitude: 31.2357),
    City(name: 'الإسكندرية', country: 'مصر', latitude: 31.2001, longitude: 29.9187),
    City(name: 'دبي', country: 'الإمارات', latitude: 25.2048, longitude: 55.2708),
    City(name: 'أبو ظبي', country: 'الإمارات', latitude: 24.4539, longitude: 54.3773),
    City(name: 'الكويت', country: 'الكويت', latitude: 29.3759, longitude: 47.9774),
    City(name: 'الدوحة', country: 'قطر', latitude: 25.2854, longitude: 51.5310),
    City(name: 'المنامة', country: 'البحرين', latitude: 26.0667, longitude: 50.5577),
    City(name: 'مسقط', country: 'عُمان', latitude: 23.5859, longitude: 58.4059),
    City(name: 'عمّان', country: 'الأردن', latitude: 31.9454, longitude: 35.9284),
    City(name: 'بيروت', country: 'لبنان', latitude: 33.8938, longitude: 35.5018),
    City(name: 'دمشق', country: 'سوريا', latitude: 33.5138, longitude: 36.2765),
    City(name: 'بغداد', country: 'العراق', latitude: 33.3152, longitude: 44.3661),
    City(name: 'صنعاء', country: 'اليمن', latitude: 15.3694, longitude: 44.1910),
    City(name: 'الخرطوم', country: 'السودان', latitude: 15.5007, longitude: 32.5599),
    City(name: 'الجزائر', country: 'الجزائر', latitude: 36.7538, longitude: 3.0588),
    City(name: 'تونس', country: 'تونس', latitude: 36.8065, longitude: 10.1815),
    City(name: 'الرباط', country: 'المغرب', latitude: 34.0209, longitude: -6.8416),
    City(name: 'الدار البيضاء', country: 'المغرب', latitude: 33.5731, longitude: -7.5898),
    City(name: 'طرابلس', country: 'ليبيا', latitude: 32.8872, longitude: 13.1913),
    City(name: 'القدس', country: 'فلسطين', latitude: 31.7683, longitude: 35.2137),
    City(name: 'غزة', country: 'فلسطين', latitude: 31.5018, longitude: 34.4668),
    City(name: 'إسطنبول', country: 'تركيا', latitude: 41.0082, longitude: 28.9784),
    City(name: 'كراتشي', country: 'باكستان', latitude: 24.8607, longitude: 67.0011),
    City(name: 'جاكرتا', country: 'إندونيسيا', latitude: -6.2088, longitude: 106.8456),
    City(name: 'كوالالمبور', country: 'ماليزيا', latitude: 3.1390, longitude: 101.6869),
    City(name: 'لندن', country: 'بريطانيا', latitude: 51.5074, longitude: -0.1278),
    City(name: 'باريس', country: 'فرنسا', latitude: 48.8566, longitude: 2.3522),
    City(name: 'برلين', country: 'ألمانيا', latitude: 52.5200, longitude: 13.4050),
    City(name: 'نيويورك', country: 'أمريكا', latitude: 40.7128, longitude: -74.0060),
  ];
}

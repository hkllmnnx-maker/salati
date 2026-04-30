import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/islamic_pattern_bg.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  StreamSubscription<CompassEvent>? _sub;
  double? _heading;
  bool _hasSensor = true;
  String? _error;

  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  @override
  void initState() {
    super.initState();
    _initCompass();
  }

  void _initCompass() {
    try {
      final stream = FlutterCompass.events;
      if (stream == null) {
        setState(() {
          _hasSensor = false;
          _error = 'حساس البوصلة غير متوفر على هذا الجهاز.';
        });
        return;
      }
      _sub = stream.listen((event) {
        if (!mounted) return;
        setState(() {
          _heading = event.heading;
          _hasSensor = event.heading != null;
        });
      }, onError: (e) {
        setState(() {
          _hasSensor = false;
          _error = 'تعذر قراءة البوصلة.';
        });
      });
    } catch (e) {
      setState(() {
        _hasSensor = false;
        _error = 'تعذر تشغيل البوصلة: $e';
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// حساب اتجاه القبلة بالدرجات من الشمال
  double _qiblaBearing(double lat, double lng) {
    final lat1 = lat * math.pi / 180;
    final lat2 = _kaabaLat * math.pi / 180;
    final dLng = (_kaabaLng - lng) * math.pi / 180;

    final y = math.sin(dLng);
    final x = math.cos(lat1) * math.tan(lat2) - math.sin(lat1) * math.cos(dLng);
    var brng = math.atan2(y, x) * 180 / math.pi;
    brng = (brng + 360) % 360;
    return brng;
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppProvider>().location;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final qibla = loc != null ? _qiblaBearing(loc.latitude, loc.longitude) : 0.0;
    final heading = _heading ?? 0;
    final rotation = ((qibla - heading) * (math.pi / 180)) * -1;
    final aligned = _hasSensor && (((qibla - heading + 360) % 360).abs() < 5 ||
        ((qibla - heading + 360) % 360).abs() > 355);

    return Scaffold(
      appBar: AppBar(title: const Text('اتجاه القبلة')),
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.gold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc != null
                                ? '${loc.city}${loc.country.isNotEmpty ? ' · ${loc.country}' : ''}'
                                : 'لم يُحدد الموقع',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Text(
                          'القبلة: ${Formatters.toArabicDigits(qibla.toStringAsFixed(0))}°',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Center(
                      child: !_hasSensor
                          ? _NoSensor(message: _error ?? 'حساس البوصلة غير متوفر.')
                          : _Compass(
                              rotation: rotation,
                              aligned: aligned,
                              heading: heading,
                              isDark: isDark,
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_hasSensor)
                    Text(
                      aligned
                          ? '✓ أنت متّجه نحو القبلة'
                          : 'وجّه أعلى الجهاز نحو السهم الذهبي',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: aligned ? AppColors.success : null,
                            fontWeight: aligned ? FontWeight.w800 : FontWeight.w600,
                          ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSensor extends StatelessWidget {
  final String message;
  const _NoSensor({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sensors_off_rounded, size: 48, color: AppColors.warning),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'تأكد من تفعيل البوصلة في إعدادات جهازك أو جرّب على جهاز آخر يحتوي على حساس مغناطيسي.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Compass extends StatelessWidget {
  final double rotation;
  final bool aligned;
  final double heading;
  final bool isDark;

  const _Compass({
    required this.rotation,
    required this.aligned,
    required this.heading,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer dial
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF1B5283), Color(0xFF062340)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          // Tick marks
          CustomPaint(
            size: const Size.fromRadius(140),
            painter: _CompassDialPainter(),
          ),
          // Direction labels
          Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                const Align(
                  alignment: Alignment.topCenter,
                  child: Text('N',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text('S',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('W',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('E',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          // Qibla arrow
          AnimatedRotation(
            turns: rotation / (2 * math.pi),
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.navigation_rounded,
                    size: 70,
                    color: aligned ? AppColors.success : AppColors.gold,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🕋',
                        style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
            ),
          ),
          // Center
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.goldLight,
            ),
          ),
          // Heading text
          Positioned(
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'الاتجاه: ${Formatters.toArabicDigits(heading.toStringAsFixed(0))}°',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.4;

    for (int i = 0; i < 60; i++) {
      final angle = i * (2 * math.pi / 60);
      final inner = i % 5 == 0 ? radius - 14 : radius - 8;
      final p1 = center + Offset(math.cos(angle) * inner, math.sin(angle) * inner);
      final p2 = center + Offset(math.cos(angle) * (radius - 4), math.sin(angle) * (radius - 4));
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

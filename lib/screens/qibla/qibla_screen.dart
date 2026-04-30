import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../../widgets/islamic_pattern_bg.dart';
import '../../widgets/section_header.dart';

/// شاشة بوصلة القبلة - تجربة فنية راقية مستوحاة من البوصلات النحاسية الكلاسيكية
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<CompassEvent>? _sub;
  double? _heading;
  bool _hasSensor = true;
  String? _error;
  late AnimationController _alignedPulse;

  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  @override
  void initState() {
    super.initState();
    _alignedPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
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
      _sub = stream.listen(
        (event) {
          if (!mounted) return;
          setState(() {
            _heading = event.heading;
            _hasSensor = event.heading != null;
          });
        },
        onError: (e) {
          if (!mounted) return;
          setState(() {
            _hasSensor = false;
            _error = 'تعذر قراءة البوصلة.';
          });
        },
      );
    } catch (e) {
      setState(() {
        _hasSensor = false;
        _error = 'تعذر تشغيل البوصلة';
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _alignedPulse.dispose();
    super.dispose();
  }

  /// حساب اتجاه القبلة بالدرجات من الشمال
  double _qiblaBearing(double lat, double lng) {
    final lat1 = lat * math.pi / 180;
    final lat2 = _kaabaLat * math.pi / 180;
    final dLng = (_kaabaLng - lng) * math.pi / 180;

    final y = math.sin(dLng);
    final x = math.cos(lat1) * math.tan(lat2) -
        math.sin(lat1) * math.cos(dLng);
    var brng = math.atan2(y, x) * 180 / math.pi;
    brng = (brng + 360) % 360;
    return brng;
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppProvider>().location;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final qibla =
        loc != null ? _qiblaBearing(loc.latitude, loc.longitude) : 0.0;
    final heading = _heading ?? 0;
    final rotation = ((qibla - heading) * (math.pi / 180)) * -1;
    final diff = ((qibla - heading + 360) % 360);
    final aligned = _hasSensor && (diff.abs() < 5 || diff.abs() > 355);

    return Scaffold(
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: Column(
              children: [
                const AppPageHeader(
                  title: 'اتجاه القبلة',
                  subtitle: 'وَجِّهْ وَجْهَكَ شَطْرَ الْمَسْجِدِ الْحَرَامِ',
                  showBackButton: false,
                  leadingIcon: Icons.explore_rounded,
                  centerTitle: false,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: _LocationBadge(
                    location: loc,
                    qiblaDegrees: qibla,
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: Center(
                      child: !_hasSensor
                          ? _NoSensor(
                              message: _error ?? 'حساس البوصلة غير متوفر.',
                            )
                          : _ArtisticCompass(
                              rotation: rotation,
                              aligned: aligned,
                              heading: heading,
                              qiblaDegrees: qibla,
                              isDark: isDark,
                              alignedAnimation: _alignedPulse,
                            ),
                    ),
                  ),
                ),
                if (_hasSensor)
                  AnimatedSwitcher(
                    duration: AppDurations.normal,
                    child: Container(
                      key: ValueKey(aligned),
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.md),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm + 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: aligned
                            ? const LinearGradient(
                                colors: [
                                  AppColors.success,
                                  Color(0xFF1F6E4A),
                                ],
                              )
                            : null,
                        color: aligned
                            ? null
                            : (isDark
                                ? AppColors.surfaceDarkElevated
                                    .withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.85)),
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        border: aligned
                            ? null
                            : Border.all(
                                color:
                                    AppColors.gold.withValues(alpha: 0.22),
                              ),
                        boxShadow: aligned
                            ? [
                                BoxShadow(
                                  color: AppColors.success
                                      .withValues(alpha: 0.32),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : AppShadows.soft(isDark: isDark),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            aligned
                                ? Icons.check_circle_rounded
                                : Icons.swap_horiz_rounded,
                            color: aligned ? Colors.white : AppColors.gold,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            aligned
                                ? 'أنت متّجه نحو القبلة'
                                : 'وجّه أعلى الجهاز نحو السهم الذهبي',
                            style: TextStyle(
                              color: aligned
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight),
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Location Badge
// ─────────────────────────────────────────────
class _LocationBadge extends StatelessWidget {
  final dynamic location;
  final double qiblaDegrees;
  final bool isDark;

  const _LocationBadge({
    required this.location,
    required this.qiblaDegrees,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDarkElevated.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.gold,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الموقع الحالي',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location != null
                      ? '${location.city}${location.country.isNotEmpty ? ' · ${location.country}' : ''}'
                      : 'لم يُحدد الموقع',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.32),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.explore_rounded,
                    color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${Formatters.toArabicDigits(qiblaDegrees.toStringAsFixed(0))}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// No Sensor State
// ─────────────────────────────────────────────
class _NoSensor extends StatelessWidget {
  final String message;
  const _NoSensor({required this.message});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.sensors_off_rounded,
      title: message,
      subtitle:
          'تأكد من تفعيل البوصلة في إعدادات جهازك أو جرّب على جهاز يحتوي على حساس مغناطيسي.',
    );
  }
}

// ─────────────────────────────────────────────
// Artistic Compass - The centerpiece
// ─────────────────────────────────────────────
class _ArtisticCompass extends StatelessWidget {
  final double rotation;
  final bool aligned;
  final double heading;
  final double qiblaDegrees;
  final bool isDark;
  final AnimationController alignedAnimation;

  const _ArtisticCompass({
    required this.rotation,
    required this.aligned,
    required this.heading,
    required this.qiblaDegrees,
    required this.isDark,
    required this.alignedAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth.clamp(0.0, 360.0);
          return Stack(
            alignment: Alignment.center,
            children: [
              // الهالة الخارجية المتموجة
              AnimatedBuilder(
                animation: alignedAnimation,
                builder: (_, __) => Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (aligned
                                ? AppColors.success
                                : AppColors.gold)
                            .withValues(
                          alpha: aligned
                              ? 0.18 + alignedAnimation.value * 0.20
                              : 0.10,
                        ),
                        blurRadius: 50,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              // القرص الخارجي النحاسي/الذهبي
              Container(
                width: size * 0.96,
                height: size * 0.96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [
                      Color(0xFFD4A84A),
                      Color(0xFFE9C77B),
                      Color(0xFFA8842F),
                      Color(0xFFD4A84A),
                      Color(0xFFE9C77B),
                      Color(0xFFD4A84A),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.32),
                      blurRadius: 24,
                      spreadRadius: -8,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                      spreadRadius: -6,
                    ),
                  ],
                ),
              ),
              // القرص الزجاجي الداخلي
              Container(
                width: size * 0.88,
                height: size * 0.88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFF1B4574),
                      Color(0xFF0F2A47),
                      Color(0xFF062340),
                    ],
                  ),
                ),
                child: ClipOval(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // علامات البوصلة (عقارب الدقائق)
                      CustomPaint(
                        size: Size(size * 0.88, size * 0.88),
                        painter: _CompassDialPainter(),
                      ),
                      // الحروف N S E W
                      Padding(
                        padding: EdgeInsets.all(size * 0.06),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: _DirectionLabel('N',
                                  color: AppColors.errorLight),
                            ),
                            const Align(
                              alignment: Alignment.bottomCenter,
                              child: _DirectionLabel('S'),
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: _DirectionLabel('W'),
                            ),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: _DirectionLabel('E'),
                            ),
                          ],
                        ),
                      ),
                      // النمط الإسلامي الخفيف في المركز
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 0.15,
                            child: CustomPaint(
                              painter: _CenterOrnamentPainter(),
                            ),
                          ),
                        ),
                      ),
                      // سهم القبلة
                      AnimatedRotation(
                        turns: rotation / (2 * math.pi),
                        duration: const Duration(milliseconds: 200),
                        curve: AppCurves.standard,
                        child: Padding(
                          padding: EdgeInsets.all(size * 0.10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // طرف السهم
                              CustomPaint(
                                size: Size(size * 0.18, size * 0.22),
                                painter: _ArrowHeadPainter(
                                  color: aligned
                                      ? AppColors.success
                                      : AppColors.gold,
                                  glow: aligned,
                                ),
                              ),
                              // الجذع المضيء
                              Container(
                                width: 4,
                                height: size * 0.20,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      (aligned
                                              ? AppColors.success
                                              : AppColors.gold)
                                          .withValues(alpha: 0.9),
                                      (aligned
                                              ? AppColors.success
                                              : AppColors.gold)
                                          .withValues(alpha: 0.0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // أيقونة الكعبة
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: aligned
                                      ? const LinearGradient(colors: [
                                          AppColors.success,
                                          Color(0xFF1F6E4A),
                                        ])
                                      : AppColors.goldGradient,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (aligned
                                              ? AppColors.success
                                              : AppColors.gold)
                                          .withValues(alpha: 0.5),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '🕋',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // المركز - مسمار نحاسي
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFFE9C77B),
                              Color(0xFFD4A84A),
                              Color(0xFF8B6920),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.55),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF6B5018),
                            ),
                          ),
                        ),
                      ),
                      // شريط الاتجاه السفلي
                      Positioned(
                        bottom: size * 0.08,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.32),
                              width: 0.7,
                            ),
                          ),
                          child: Text(
                            'الاتجاه: ${Formatters.toArabicDigits(heading.toStringAsFixed(0))}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Direction Label (N, S, E, W)
// ─────────────────────────────────────────────
class _DirectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _DirectionLabel(this.text, {this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color.withValues(alpha: color == Colors.white ? 0.82 : 1),
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
        shadows: [
          Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Compass Dial Painter (tick marks)
// ─────────────────────────────────────────────
class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // علامات صغيرة كل 6 درجات + علامات كبيرة كل 30 درجة
    for (int i = 0; i < 60; i++) {
      final angle = i * (2 * math.pi / 60) - math.pi / 2;
      final isMajor = i % 5 == 0;
      final inner = isMajor ? radius - 18 : radius - 10;
      final outer = radius - 4;
      final paint = Paint()
        ..color = isMajor
            ? AppColors.goldLight.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.30)
        ..strokeWidth = isMajor ? 2 : 1
        ..strokeCap = StrokeCap.round;
      final p1 = center +
          Offset(math.cos(angle) * inner, math.sin(angle) * inner);
      final p2 = center +
          Offset(math.cos(angle) * outer, math.sin(angle) * outer);
      canvas.drawLine(p1, p2, paint);
    }

    // حلقة داخلية رفيعة
    final ringPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 30, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// Center Ornament Painter
// ─────────────────────────────────────────────
class _CenterOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.18;
    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    // نجمة ثمانية بسيطة
    final path = Path();
    for (int i = 0; i < 16; i++) {
      final angle = i * math.pi / 8 - math.pi / 2;
      final radius = i.isEven ? r : r * 0.42;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// Arrow Head Painter - decorative arrow
// ─────────────────────────────────────────────
class _ArrowHeadPainter extends CustomPainter {
  final Color color;
  final bool glow;
  _ArrowHeadPainter({required this.color, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // طبقة التوهج
    if (glow) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      final glowPath = Path()
        ..moveTo(w / 2, 0)
        ..lineTo(w * 0.85, h * 0.85)
        ..lineTo(w / 2, h * 0.65)
        ..lineTo(w * 0.15, h * 0.85)
        ..close();
      canvas.drawPath(glowPath, glowPaint);
    }

    // السهم الرئيسي بتدرج
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(color, Colors.white, 0.4) ?? color,
        color,
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final fillPaint = Paint()..shader = shader;
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w * 0.85, h * 0.85)
      ..lineTo(w / 2, h * 0.65)
      ..lineTo(w * 0.15, h * 0.85)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _ArrowHeadPainter old) =>
      old.color != color || old.glow != glow;
}

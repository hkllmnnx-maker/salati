import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../../widgets/islamic_pattern_bg.dart';
import '../../widgets/section_header.dart';

/// شاشة السبحة الإلكترونية - تجربة تسبيح فاخرة وعصرية
class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen>
    with TickerProviderStateMixin {
  final StorageService _storage = StorageService();
  int _count = 0;
  int _target = 33;
  String _phrase = 'سُبْحَانَ اللَّهِ';

  late AnimationController _tapCtrl;
  late AnimationController _glowCtrl;

  final List<String> _phrases = const [
    'سُبْحَانَ اللَّهِ',
    'الْحَمْدُ لِلَّهِ',
    'اللَّهُ أَكْبَرُ',
    'لَا إِلَهَ إِلَّا اللَّهُ',
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    'أَسْتَغْفِرُ اللَّهَ',
  ];

  final List<int> _targets = const [33, 99, 100];

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _load();
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final c = await _storage.loadTasbeehCount();
    if (!mounted) return;
    setState(() => _count = c);
  }

  void _increment() {
    HapticFeedback.lightImpact();
    setState(() => _count++);
    _storage.saveTasbeehCount(_count);
    _tapCtrl.forward(from: 0).then((_) => _tapCtrl.reverse());
    if (_count > 0 && _count % _target == 0) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _confirmReset() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.restart_alt_rounded,
            color: AppColors.warning,
            size: 30,
          ),
        ),
        title: const Text('إعادة ضبط', textAlign: TextAlign.center),
        content: const Text(
          'هل تريد إعادة ضبط عداد التسبيح إلى الصفر؟',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    if (result == true) {
      setState(() => _count = 0);
      _storage.saveTasbeehCount(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inCycle = _count % _target;
    final progress = inCycle / _target;
    final cycles = _count ~/ _target;

    return Scaffold(
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: Column(
              children: [
                AppPageHeader(
                  title: 'السبحة الإلكترونية',
                  subtitle: 'سَبِّحْ بِحَمْدِ رَبِّكَ',
                  showBackButton: true,
                  centerTitle: false,
                  actions: [
                    CircleIconAction(
                      icon: Icons.restart_alt_rounded,
                      tooltip: 'إعادة ضبط',
                      onTap: _confirmReset,
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        _PhraseSelector(
                          phrases: _phrases,
                          current: _phrase,
                          onSelected: (p) => setState(() => _phrase = p),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _TargetSelector(
                          targets: _targets,
                          current: _target,
                          onSelected: (t) => setState(() => _target = t),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Expanded(
                          child: Center(
                            child: AnimatedBuilder(
                              animation: Listenable.merge(
                                  [_tapCtrl, _glowCtrl]),
                              builder: (_, __) {
                                final scale = 1.0 - (_tapCtrl.value * 0.04);
                                final glow = 0.18 + (_glowCtrl.value * 0.18);
                                return Transform.scale(
                                  scale: scale,
                                  child: GestureDetector(
                                    onTap: _increment,
                                    child: _CounterRing(
                                      progress: progress,
                                      count: inCycle,
                                      total: _target,
                                      totalAll: _count,
                                      cycles: cycles,
                                      phrase: _phrase,
                                      glowIntensity: glow,
                                      isDark: isDark,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 14,
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'انقر على الدائرة الذهبية للتسبيح',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiaryLight,
                                ),
                              ),
                            ],
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
// Phrase Selector - Horizontal Chips
// ─────────────────────────────────────────────
class _PhraseSelector extends StatelessWidget {
  final List<String> phrases;
  final String current;
  final ValueChanged<String> onSelected;

  const _PhraseSelector({
    required this.phrases,
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: phrases.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final p = phrases[i];
          final selected = current == p;
          return AnimatedContainer(
            duration: AppDurations.fast,
            curve: AppCurves.standard,
            decoration: BoxDecoration(
              gradient: selected ? AppColors.goldGradient : null,
              color: selected
                  ? null
                  : isDark
                      ? AppColors.surfaceDarkElevated
                      : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : AppColors.gold.withValues(alpha: 0.22),
                width: 1,
              ),
              boxShadow:
                  selected ? AppShadows.goldGlow(intensity: 0.22) : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: () => onSelected(p),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Center(
                    child: Text(
                      p,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: selected ? Colors.white : AppColors.gold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Target Selector
// ─────────────────────────────────────────────
class _TargetSelector extends StatelessWidget {
  final List<int> targets;
  final int current;
  final ValueChanged<int> onSelected;

  const _TargetSelector({
    required this.targets,
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'الهدف:',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: 10),
        ...targets.map((t) {
          final selected = current == t;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(t),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 50,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.gold.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: selected
                          ? AppColors.gold.withValues(alpha: 0.55)
                          : AppColors.gold.withValues(alpha: 0.18),
                      width: selected ? 1.4 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      Formatters.toArabicDigits(t.toString()),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? AppColors.gold
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Counter Ring - Premium Circular Counter
// ─────────────────────────────────────────────
class _CounterRing extends StatelessWidget {
  final double progress;
  final int count;
  final int total;
  final int totalAll;
  final int cycles;
  final String phrase;
  final double glowIntensity;
  final bool isDark;

  const _CounterRing({
    required this.progress,
    required this.count,
    required this.total,
    required this.totalAll,
    required this.cycles,
    required this.phrase,
    required this.glowIntensity,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth.clamp(0.0, 320.0);
          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // التوهج الخارجي المتموج
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: glowIntensity),
                        blurRadius: 50,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
                // الحلقة الخارجية بنمط المسبحة
                CustomPaint(
                  size: Size(size, size),
                  painter: _BeadsRingPainter(
                    progress: progress,
                    isDark: isDark,
                  ),
                ),
                // حلقة التقدم الذهبية الناعمة
                SizedBox(
                  width: size * 0.86,
                  height: size * 0.86,
                  child: TweenAnimationBuilder<double>(
                    duration: AppDurations.normal,
                    curve: AppCurves.emphasized,
                    tween: Tween(begin: 0, end: progress),
                    builder: (_, value, __) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      backgroundColor: isDark
                          ? AppColors.gold.withValues(alpha: 0.10)
                          : AppColors.gold.withValues(alpha: 0.14),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.gold),
                    ),
                  ),
                ),
                // الدائرة الداخلية الفاخرة
                Container(
                  width: size * 0.74,
                  height: size * 0.74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.heroCardGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 32,
                        offset: const Offset(0, 14),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.18),
                        blurRadius: 24,
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _InnerOrnamentPainter(),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -size * 0.15,
                          left: -size * 0.10,
                          right: -size * 0.10,
                          child: Container(
                            height: size * 0.45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.18),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                phrase,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  color: AppColors.goldLight,
                                  fontSize: size > 280 ? 20 : 17,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8),
                              ShaderMask(
                                shaderCallback: (rect) =>
                                    const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white,
                                    AppColors.goldLight,
                                  ],
                                ).createShader(rect),
                                child: Text(
                                  Formatters.toArabicDigits(
                                      count.toString()),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size > 280 ? 72 : 60,
                                    fontWeight: FontWeight.w900,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                    height: 1.0,
                                    letterSpacing: -2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(
                                      AppRadius.pill),
                                ),
                                child: Text(
                                  'الكلي: ${Formatters.toArabicDigits(totalAll.toString())}',
                                  style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.85),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (cycles > 0) ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.workspace_premium_rounded,
                                      color: AppColors.goldLight,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${Formatters.toArabicDigits(cycles.toString())} دورة',
                                      style: const TextStyle(
                                        color: AppColors.goldLight,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Beads Ring Painter - Decorative bead pattern around the counter
// ─────────────────────────────────────────────
class _BeadsRingPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _BeadsRingPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const beadRadius = 3.5;
    const beadCount = 33;

    final activeBeads = (progress * beadCount).round();

    for (int i = 0; i < beadCount; i++) {
      final angle = (i / beadCount) * 2 * math.pi - math.pi / 2;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      final isActive = i < activeBeads;
      final paint = Paint()
        ..color = isActive
            ? AppColors.gold
            : isDark
                ? AppColors.gold.withValues(alpha: 0.18)
                : AppColors.gold.withValues(alpha: 0.22);
      if (isActive) {
        // توهج ناعم على الخرز النشط
        final glowPaint = Paint()
          ..color = AppColors.gold.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(dx, dy), beadRadius + 1.5, glowPaint);
      }
      canvas.drawCircle(Offset(dx, dy), beadRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BeadsRingPainter old) =>
      old.progress != progress || old.isDark != isDark;
}

// ─────────────────────────────────────────────
// Inner ornament painter - decorative pattern in the gold disc
// ─────────────────────────────────────────────
class _InnerOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    // دوائر متمركزة
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, (size.width / 2 - 6) * (i / 5), paint);
    }
    // ثمان نجمات حول المركز
    final starPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    final r = size.width / 2 - 16;
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi - math.pi / 2;
      final dx = center.dx + r * 0.55 * math.cos(angle);
      final dy = center.dy + r * 0.55 * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 1.2, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

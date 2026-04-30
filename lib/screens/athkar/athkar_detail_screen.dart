import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/athkar_data.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/islamic_pattern_bg.dart';
import '../../widgets/section_header.dart';

/// شاشة عرض الذكر التفصيلية - تجربة قراءة فاخرة
class AthkarDetailScreen extends StatefulWidget {
  final AthkarCategory category;
  const AthkarDetailScreen({super.key, required this.category});

  @override
  State<AthkarDetailScreen> createState() => _AthkarDetailScreenState();
}

class _AthkarDetailScreenState extends State<AthkarDetailScreen> {
  final StorageService _storage = StorageService();
  final PageController _pageController = PageController();
  Map<int, int> _progress = {};
  bool _hideRef = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await _storage.loadAthkarProgress(widget.category.id);
    if (!mounted) return;
    setState(() => _progress = p);
  }

  Future<void> _save() async {
    await _storage.saveAthkarProgress(widget.category.id, _progress);
  }

  void _increment(int idx) {
    final dhikr = widget.category.items[idx];
    final cur = _progress[idx] ?? 0;
    if (cur >= dhikr.repeat) return;
    HapticFeedback.lightImpact();
    setState(() => _progress[idx] = cur + 1);
    _save();
    // الانتقال التلقائي عند الإكمال
    if ((cur + 1) >= dhikr.repeat &&
        idx < widget.category.items.length - 1) {
      Future.delayed(const Duration(milliseconds: 380), () {
        if (!mounted) return;
        _pageController.nextPage(
          duration: AppDurations.normal,
          curve: AppCurves.emphasized,
        );
      });
    }
  }

  void _resetCurrent(int idx) {
    HapticFeedback.selectionClick();
    setState(() => _progress[idx] = 0);
    _save();
  }

  Future<void> _resetAll() async {
    setState(() => _progress = {});
    await _storage.clearAthkarProgress(widget.category.id);
  }

  Future<void> _shareCurrent(int idx) async {
    final d = widget.category.items[idx];
    final text = '${d.text}\n\n${d.reference ?? ''}\n\n— من تطبيق صلاتي';
    await Share.share(text);
  }

  Future<bool> _confirmReset() async {
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
          'هل تريد إعادة ضبط جميع العدادات لهذه المجموعة؟',
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
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.category.items;
    final completed = items
        .asMap()
        .entries
        .where((e) => (_progress[e.key] ?? 0) >= e.value.repeat)
        .length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: Column(
              children: [
                AppPageHeader(
                  title: widget.category.title,
                  subtitle: widget.category.subtitle,
                  showBackButton: true,
                  centerTitle: false,
                  actions: [
                    CircleIconAction(
                      icon: _hideRef
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      tooltip: _hideRef ? 'إظهار الشرح' : 'إخفاء الشرح',
                      onTap: () => setState(() => _hideRef = !_hideRef),
                    ),
                    const SizedBox(width: 6),
                    CircleIconAction(
                      icon: Icons.restart_alt_rounded,
                      tooltip: 'إعادة ضبط',
                      onTap: () async {
                        if (await _confirmReset()) _resetAll();
                      },
                    ),
                  ],
                ),
                // شريط التقدم الفاخر
                _ProgressHeader(
                  completed: completed,
                  total: items.length,
                  current: _currentIndex,
                ),
                const SizedBox(height: AppSpacing.sm),
                // محتوى الأذكار
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: items.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemBuilder: (context, idx) {
                      final d = items[idx];
                      final count = _progress[idx] ?? 0;
                      final done = count >= d.repeat;
                      return _DhikrPageView(
                        dhikr: d,
                        index: idx,
                        total: items.length,
                        count: count,
                        done: done,
                        hideRef: _hideRef,
                        onIncrement: () => _increment(idx),
                        onReset: () => _resetCurrent(idx),
                        onShare: () => _shareCurrent(idx),
                        isDark: isDark,
                      );
                    },
                  ),
                ),
                // مؤشرات الصفحة
                _PageIndicator(
                  total: items.length,
                  current: _currentIndex,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Progress Header
// ─────────────────────────────────────────────
class _ProgressHeader extends StatelessWidget {
  final int completed;
  final int total;
  final int current;
  const _ProgressHeader({
    required this.completed,
    required this.total,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = total == 0 ? 0.0 : completed / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDarkElevated.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          children: [
            // الدائرة المئوية
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor:
                          AppColors.gold.withValues(alpha: 0.15),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.gold),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التقدم في القراءة',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '$completed',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.gold,
                        ),
                      ),
                      Text(
                        ' من $total ذكر',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.08),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'صفحة ${current + 1} / $total',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark ? AppColors.goldLight : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Dhikr Page View - the heart of the experience
// ─────────────────────────────────────────────
class _DhikrPageView extends StatelessWidget {
  final Dhikr dhikr;
  final int index;
  final int total;
  final int count;
  final bool done;
  final bool hideRef;
  final VoidCallback onIncrement;
  final VoidCallback onReset;
  final VoidCallback onShare;
  final bool isDark;

  const _DhikrPageView({
    required this.dhikr,
    required this.index,
    required this.total,
    required this.count,
    required this.done,
    required this.hideRef,
    required this.onIncrement,
    required this.onReset,
    required this.onShare,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          // بطاقة الذكر الفاخرة
          Expanded(
            child: AnimatedContainer(
              duration: AppDurations.normal,
              curve: AppCurves.standard,
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.surfaceDarkElevated.withValues(alpha: 0.92),
                          AppColors.surfaceDark.withValues(alpha: 0.78),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.98),
                          Colors.white.withValues(alpha: 0.86),
                        ],
                      ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: done
                      ? AppColors.gold.withValues(alpha: 0.55)
                      : (isDark
                          ? AppColors.gold.withValues(alpha: 0.10)
                          : AppColors.primary.withValues(alpha: 0.07)),
                  width: done ? 1.5 : 1,
                ),
                boxShadow: done
                    ? AppShadows.goldGlow(intensity: 0.18)
                    : AppShadows.soft(isDark: isDark),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Stack(
                  children: [
                    // زخرفة عليا - قوس ذهبي
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gold.withValues(alpha: 0),
                              AppColors.gold.withValues(alpha: done ? 1 : 0.6),
                              AppColors.gold.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // شريحة ترقيم
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              'الذكر ${Formatters.toArabicDigits('${index + 1}')} من ${Formatters.toArabicDigits('$total')}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // النص العربي بخط Amiri الفاخر
                          Text(
                            dhikr.text,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 22,
                              height: 2.05,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.primaryDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (!hideRef && dhikr.reference != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            const GoldDivider(height: 16),
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.sm + 2),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.gold.withValues(alpha: 0.07),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: AppColors.gold
                                      .withValues(alpha: 0.18),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.auto_stories_rounded,
                                    color: AppColors.gold
                                        .withValues(alpha: 0.85),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      dhikr.reference!,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        height: 1.6,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.goldLight
                                            : AppColors.goldDark,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // أزرار التحكم - شريط أنيق
          Row(
            children: [
              _ActionButton(
                icon: Icons.share_rounded,
                onTap: onShare,
                tooltip: 'مشاركة',
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _ActionButton(
                icon: Icons.refresh_rounded,
                onTap: onReset,
                tooltip: 'إعادة العداد',
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              // الزر الرئيسي - عداد التسبيح الفاخر
              Expanded(
                child: _CounterButton(
                  count: count,
                  total: dhikr.repeat,
                  done: done,
                  onTap: onIncrement,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Action Button (Share / Reset)
// ─────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            width: 56,
            height: 64,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDarkElevated
                  : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.22),
              ),
              boxShadow: AppShadows.soft(isDark: isDark),
            ),
            child: Icon(
              icon,
              color: AppColors.gold,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Counter Button - Large Premium Tasbeeh Button
// ─────────────────────────────────────────────
class _CounterButton extends StatelessWidget {
  final int count;
  final int total;
  final bool done;
  final VoidCallback onTap;

  const _CounterButton({
    required this.count,
    required this.total,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 1.0 : count / total;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: AppDurations.normal,
          curve: AppCurves.standard,
          height: 64,
          decoration: BoxDecoration(
            gradient: done
                ? const LinearGradient(
                    colors: [AppColors.success, Color(0xFF1F6E4A)],
                  )
                : AppColors.heroCardGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: (done ? AppColors.success : AppColors.primary)
                    .withValues(alpha: 0.32),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Stack(
              children: [
                // شريط التقدم في الخلفية
                AnimatedContainer(
                  duration: AppDurations.fast,
                  curve: AppCurves.emphasized,
                  width: progress * MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                // المحتوى
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        done
                            ? Icons.check_circle_rounded
                            : Icons.touch_app_rounded,
                        color: done ? Colors.white : AppColors.goldLight,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        done
                            ? 'تم بحمد الله'
                            : '${Formatters.toArabicDigits('$count')} / ${Formatters.toArabicDigits('$total')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Page Indicator (dots)
// ─────────────────────────────────────────────
class _PageIndicator extends StatelessWidget {
  final int total;
  final int current;
  const _PageIndicator({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    final maxVisible = 9;
    final showDots = total <= maxVisible;
    if (!showDots) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: AppDurations.normal,
          curve: AppCurves.emphasized,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.goldGradient : null,
            color: isActive ? null : AppColors.gold.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        );
      }),
    );
  }
}

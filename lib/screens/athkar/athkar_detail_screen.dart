import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/athkar_data.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/islamic_pattern_bg.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _storage.loadAthkarProgress(widget.category.id);
    setState(() => _progress = p);
  }

  Future<void> _save() async {
    await _storage.saveAthkarProgress(widget.category.id, _progress);
  }

  void _increment(int idx) {
    final dhikr = widget.category.items[idx];
    final cur = _progress[idx] ?? 0;
    if (cur >= dhikr.repeat) return;
    setState(() {
      _progress[idx] = cur + 1;
    });
    _save();
  }

  void _resetCurrent(int idx) {
    setState(() => _progress[idx] = 0);
    _save();
  }

  void _resetAll() async {
    setState(() => _progress = {});
    await _storage.clearAthkarProgress(widget.category.id);
  }

  Future<void> _shareCurrent(int idx) async {
    final d = widget.category.items[idx];
    final text = '${d.text}\n\n${d.reference ?? ''}\n\n— من تطبيق صلاتي';
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.category.items;
    final completed = items.asMap().entries.where((e) => (_progress[e.key] ?? 0) >= e.value.repeat).length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
        actions: [
          IconButton(
            tooltip: _hideRef ? 'إظهار الشرح' : 'إخفاء الشرح',
            icon: Icon(_hideRef ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _hideRef = !_hideRef),
          ),
          IconButton(
            tooltip: 'إعادة ضبط',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('إعادة ضبط'),
                  content: const Text('هل تريد إعادة ضبط جميع العدادات؟'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد')),
                  ],
                ),
              );
              if (confirmed == true) _resetAll();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: items.isEmpty ? 0 : completed / items.length,
                            minHeight: 8,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('$completed/${items.length}',
                          style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: items.length,
                    onPageChanged: (i) => setState(() {}),
                    itemBuilder: (context, idx) {
                      final d = items[idx];
                      final count = _progress[idx] ?? 0;
                      final done = count >= d.repeat;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context).cardColor,
                                        Theme.of(context).cardColor.withValues(alpha: 0.85),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: done
                                          ? AppColors.gold.withValues(alpha: 0.6)
                                          : AppColors.primary.withValues(alpha: 0.08),
                                      width: done ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text('${idx + 1} من ${items.length}',
                                            style: Theme.of(context).textTheme.bodySmall),
                                      ),
                                      const SizedBox(height: 18),
                                      Text(
                                        d.text,
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                              fontSize: 22,
                                              height: 2.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (!_hideRef && d.reference != null) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.gold.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            d.reference!,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  fontStyle: FontStyle.italic,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _shareCurrent(idx),
                                  icon: const Icon(Icons.share_rounded),
                                  tooltip: 'مشاركة',
                                ),
                                IconButton(
                                  onPressed: () => _resetCurrent(idx),
                                  icon: const Icon(Icons.refresh_rounded),
                                  tooltip: 'إعادة العداد',
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _increment(idx),
                                    child: Container(
                                      height: 70,
                                      decoration: BoxDecoration(
                                        gradient: done
                                            ? const LinearGradient(colors: [AppColors.success, Color(0xFF1F6E4A)])
                                            : AppColors.cardGradient,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (done ? AppColors.success : AppColors.primary)
                                                .withValues(alpha: 0.3),
                                            blurRadius: 14,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            done ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            done ? 'تم بحمد الله' : '$count / ${d.repeat}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/islamic_pattern_bg.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  final StorageService _storage = StorageService();
  int _count = 0;
  int _target = 33;
  String _phrase = 'سُبْحَانَ اللَّهِ';

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
    _load();
  }

  Future<void> _load() async {
    final c = await _storage.loadTasbeehCount();
    setState(() => _count = c);
  }

  void _increment() {
    HapticFeedback.lightImpact();
    setState(() => _count++);
    _storage.saveTasbeehCount(_count);
  }

  void _reset() {
    setState(() => _count = 0);
    _storage.saveTasbeehCount(0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_count % _target) / _target;
    final cycles = _count ~/ _target;
    return Scaffold(
      appBar: AppBar(title: const Text('السبحة الإلكترونية'), actions: [
        IconButton(onPressed: _reset, icon: const Icon(Icons.restart_alt_rounded)),
      ]),
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // اختيار الذكر
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _phrases.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final p = _phrases[i];
                        final selected = _phrase == p;
                        return ChoiceChip(
                          label: Text(p),
                          selected: selected,
                          onSelected: (_) => setState(() => _phrase = p),
                          selectedColor: AppColors.gold.withValues(alpha: 0.25),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // الهدف
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('الهدف:'),
                      const SizedBox(width: 8),
                      ..._targets.map((t) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(Formatters.toArabicDigits(t.toString())),
                              selected: _target == t,
                              onSelected: (_) => setState(() => _target = t),
                            ),
                          )),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _increment,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 280,
                              height: 280,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 14,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                                valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                              ),
                            ),
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.cardGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _phrase,
                                    style: const TextStyle(
                                      color: AppColors.goldLight,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    Formatters.toArabicDigits((_count % _target).toString()),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 64,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    'الكلي: ${Formatters.toArabicDigits(_count.toString())}',
                                    style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                                  ),
                                  if (cycles > 0)
                                    Text(
                                      'مرات مكتملة: ${Formatters.toArabicDigits(cycles.toString())}',
                                      style: const TextStyle(
                                          color: AppColors.goldLight,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'انقر على الدائرة للتسبيح',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

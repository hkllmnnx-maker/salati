import 'package:flutter/material.dart';
import '../../data/quran_data.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/islamic_pattern_bg.dart';

class SurahScreen extends StatelessWidget {
  final Surah surah;
  const SurahScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    final hasContent = surah.sampleAyat.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text('سورة ${surah.nameAr}')),
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.menu_book_rounded, color: AppColors.goldLight, size: 40),
                        const SizedBox(height: 8),
                        Text('سورة ${surah.nameAr}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            )),
                        const SizedBox(height: 4),
                        Text(
                          '${surah.revelation} · ${Formatters.toArabicDigits(surah.ayahCount.toString())} آية · رقم ${Formatters.toArabicDigits(surah.number.toString())}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (hasContent) ...[
                    for (int i = 0; i < surah.sampleAyat.length; i++)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (i != 0)
                              Container(
                                width: 32,
                                height: 32,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.gold.withValues(alpha: 0.18),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  Formatters.toArabicDigits(i.toString()),
                                  style: const TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                surah.sampleAyat[i],
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontFamily: 'Amiri',
                                      fontSize: 22,
                                      height: 2.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.auto_stories_rounded,
                              size: 48, color: AppColors.gold),
                          const SizedBox(height: 12),
                          Text('قريبًا',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Text(
                            'محتوى هذه السورة سيتم توفيره في تحديثات قادمة عبر مصدر معتمد للقرآن الكريم. متاحة حاليًا: الفاتحة، عدد من قصار المفصّل والمعوّذات.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

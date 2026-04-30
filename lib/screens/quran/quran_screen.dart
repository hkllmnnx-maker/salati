import 'package:flutter/material.dart';
import '../../data/quran_data.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/islamic_pattern_bg.dart';
import 'surah_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = QuranData.surahs.where((s) {
      if (_query.isEmpty) return true;
      return s.nameAr.contains(_query) ||
          s.nameEnglish.toLowerCase().contains(_query.toLowerCase()) ||
          s.number.toString() == _query;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('القرآن الكريم')),
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'بحث عن سورة...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final s = filtered[i];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.06),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          leading: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.star_rounded, color: AppColors.gold.withValues(alpha: 0.85), size: 44),
                              Text(
                                Formatters.toArabicDigits(s.number.toString()),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            'سورة ${s.nameAr}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            '${s.revelation} · ${Formatters.toArabicDigits(s.ayahCount.toString())} آية',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: Icon(
                            s.sampleAyat.isNotEmpty
                                ? Icons.menu_book_rounded
                                : Icons.lock_outline_rounded,
                            color: s.sampleAyat.isNotEmpty
                                ? AppColors.gold
                                : Theme.of(context).iconTheme.color?.withValues(alpha: 0.4),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => SurahScreen(surah: s),
                            ));
                          },
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

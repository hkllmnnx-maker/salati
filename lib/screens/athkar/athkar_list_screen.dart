import 'package:flutter/material.dart';
import '../../data/athkar_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/islamic_pattern_bg.dart';
import 'athkar_detail_screen.dart';

class AthkarListScreen extends StatelessWidget {
  const AthkarListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأذكار')),
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: AthkarData.all.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final c = AthkarData.all[i];
                return GlassCard(
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AthkarDetailScreen(category: c),
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(c.icon,
                                style: const TextStyle(fontSize: 28)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(c.subtitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                                const SizedBox(height: 6),
                                Text('${c.items.length} ذكرًا',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.gold,
                                          fontWeight: FontWeight.w700,
                                        )),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

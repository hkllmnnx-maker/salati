import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/islamic_pattern_bg.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عن التطبيق')),
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset('assets/icons/app_icon.png', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('صلاتي',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.gold,
                          )),
                  const SizedBox(height: 6),
                  Text('الإصدار ١٫٠٫٠',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'تطبيق إسلامي عربي احترافي يجمع أوقات الصلاة، الأذكار، القبلة، التقويم الهجري، والقرآن الكريم في تجربة واحدة بتصميم عصري راقٍ.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 14),
                        const Divider(),
                        const SizedBox(height: 8),
                        _featureRow(context, Icons.access_time, 'حساب أوقات الصلاة بطرق متعددة'),
                        _featureRow(context, Icons.menu_book_rounded, 'الأذكار والقرآن الكريم'),
                        _featureRow(context, Icons.explore_rounded, 'بوصلة القبلة'),
                        _featureRow(context, Icons.calendar_month_rounded, 'تقويم هجري وميلادي'),
                        _featureRow(context, Icons.notifications_active_rounded, 'إشعارات قبل الصلاة'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'اللهم تقبّل منا، إنك أنت السميع العليم.\nاللهم اجعل هذا العمل خالصًا لوجهك الكريم.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontFamily: 'Amiri',
                            color: AppColors.gold,
                            height: 1.8,
                          ),
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

  Widget _featureRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

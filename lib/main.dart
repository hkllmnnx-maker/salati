import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'widgets/islamic_pattern_bg.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SalatiApp());
}

class SalatiApp extends StatelessWidget {
  const SalatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..bootstrap(),
      child: Consumer<AppProvider>(
        builder: (context, app, _) {
          return MaterialApp(
            title: 'صلاتي',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: app.themeMode,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return Directionality(
                textDirection: TextDirection.rtl,
                child: MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(app.fontScale),
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
            home: const _Bootstrap(),
          );
        },
      ),
    );
  }
}

class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>().state;
    if (state == AppLoadState.ready) return const MainShell();
    if (state == AppLoadState.error) {
      return Scaffold(
        body: Stack(
          children: [
            const IslamicPatternBackground(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text('تعذّر بدء التطبيق',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => context.read<AppProvider>().bootstrap(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
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
                const SizedBox(height: 24),
                Text('صلاتي',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.gold,
                        )),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.gold,
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/plan_setup_screen.dart';
import 'services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'providers/reading_provider.dart';
import 'providers/dhikr_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/gamification_provider.dart';
import 'screens/enhanced_settings_screen.dart';
import 'screens/enhanced_onboarding_screen.dart';
import 'screens/enhanced_home_screen.dart';
import 'screens/enhanced_reading_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/quran_data.dart';
import 'services/local_quran_service.dart';
import 'services/tafseer_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  } catch (e) {
    debugPrint('Database initialization error: $e');
  }

  runApp(const KhatmatiApp());
}

class KhatmatiApp extends StatefulWidget {
  const KhatmatiApp({super.key});

  @override
  State<KhatmatiApp> createState() => _KhatmatiAppState();
}

class _KhatmatiAppState extends State<KhatmatiApp> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // تحميل بيانات القرآن (metadata + full text + tafseer)
      await QuranData.loadQuranData();
      await LocalQuranService.loadQuranData();
      await TafseerService.loadTafseer();

      // تهيئة الخدمات بعد بناء التطبيق
      await NotificationService().initialize();
      await NotificationService().requestPermissions();
      await NotificationService().scheduleDailyDhikrReminders();

      // قفل الاتجاه العمودي فقط
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } catch (e) {
      // تجاهل الأخطاء في حالة الفشل (للسماح بالمعاينة)
      debugPrint('Service initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReadingProvider()),
        ChangeNotifierProvider(create: (_) => DhikrProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ختمتي - رفيقك في رحلة القرآن الكريم',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: const Locale('ar', 'SA'),
            supportedLocales: const [
              Locale('ar', 'SA'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const RootHandler(),
            routes: {
              '/plan': (context) => const PlanSetupScreen(),
              '/plan-setup': (context) => const PlanSetupScreen(),
              '/reading': (context) => const EnhancedReadingScreen(),
              '/settings': (context) => const EnhancedSettingsScreen(),
              '/onboarding': (context) => const EnhancedOnboardingScreen(),
              '/home': (context) => const EnhancedHomeScreen(),
            },
          );
        },
      ),
    );
  }
}

class RootHandler extends StatelessWidget {
  const RootHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ختمتي',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'رفيقك في رحلة القرآن الكريم',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (!provider.hasProfile) {
          return const EnhancedOnboardingScreen();
        }

        return const MainNavigationScreen();
      },
    );
  }
}

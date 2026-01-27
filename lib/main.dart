import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/reading_screen.dart';
import 'screens/dhikr_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/plan_setup_screen.dart';
import 'services/notification_service.dart';
import 'services/notification_scheduler.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'providers/reading_provider.dart';
import 'providers/dhikr_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/quran_data.dart';
import 'services/local_quran_service.dart';
import 'services/tafseer_service.dart';

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

class _KhatmatiAppState extends State<KhatmatiApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // إعادة جدولة التنبيهات عند العودة للتطبيق (يوم جديد مثلاً)
      _rescheduleIfNeeded();
    }
  }

  Future<void> _rescheduleIfNeeded() async {
    try {
      final scheduler = NotificationScheduler();
      if (await scheduler.needsReschedule()) {
        await scheduler.scheduleAllNotifications();
      }
    } catch (e) {
      debugPrint('Reschedule error: $e');
    }
  }

  Future<void> _initializeServices() async {
    try {
      // تحميل بيانات القرآن (metadata + full text + tafseer)
      await QuranData.loadQuranData();
      await LocalQuranService.loadQuranData();
      await TafseerService.loadTafseer();

      // تهيئة خدمة الإشعارات
      await NotificationService().initialize();
      await NotificationService().requestPermissions();

      // جدولة جميع التنبيهات الفعلية بناءً على الموقع والإعدادات
      final scheduler = NotificationScheduler();
      if (await scheduler.needsReschedule()) {
        await scheduler.scheduleAllNotifications();
      }

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
      ],
      child: MaterialApp(
        title: 'ختمتي - رفيقك في رحلة القرآن الكريم',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFF1B5E20), // أخضر داكن
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B5E20),
            brightness: Brightness.light,
          ),
          fontFamily: 'Amiri',
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
            displayMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
            bodyLarge: TextStyle(
              fontSize: 18,
              color: Color(0xFF424242),
            ),
            bodyMedium: TextStyle(
              fontSize: 16,
              color: Color(0xFF616161),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Color(0xFF1B5E20),
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        ),
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
          '/reading': (context) => const ReadingScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!provider.hasProfile) {
          return const OnboardingScreen();
        }

        return const MainNavigationScreen();
      },
    );
  }
}

/// الواجهة الرئيسية مع التنقل السفلي
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ReadingScreen(),
    DhikrScreen(),
    StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'القراءة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote_rounded),
            label: 'الأذكار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'الإحصائيات',
          ),
        ],
      ),
    );
  }
}

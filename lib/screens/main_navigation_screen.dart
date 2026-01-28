import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/gamification_provider.dart';
import 'enhanced_home_screen.dart';
import 'enhanced_reading_screen.dart';
import 'enhanced_dhikr_screen.dart';
import 'enhanced_statistics_screen.dart';
import 'enhanced_settings_screen.dart';

/// الشاشة الرئيسية المحسّنة مع التنقل السفلي والقائمة الجانبية
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    EnhancedHomeScreen(),
    EnhancedReadingScreen(),
    EnhancedDhikrScreen(),
    EnhancedStatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: _buildEnhancedDrawer(theme),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: theme.cardColor,
        indicatorColor: theme.colorScheme.primary.withOpacity(0.15),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined,
                color: theme.colorScheme.onSurface.withOpacity(0.5)),
            selectedIcon:
                Icon(Icons.home_rounded, color: theme.colorScheme.primary),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined,
                color: theme.colorScheme.onSurface.withOpacity(0.5)),
            selectedIcon:
                Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary),
            label: 'القراءة',
          ),
          NavigationDestination(
            icon: Icon(Icons.format_quote_outlined,
                color: theme.colorScheme.onSurface.withOpacity(0.5)),
            selectedIcon: Icon(Icons.format_quote_rounded,
                color: theme.colorScheme.primary),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined,
                color: theme.colorScheme.onSurface.withOpacity(0.5)),
            selectedIcon: Icon(Icons.bar_chart_rounded,
                color: theme.colorScheme.primary),
            label: 'الإحصائيات',
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDrawer(ThemeData theme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(theme),
          _buildDrawerItem(
            theme,
            Icons.home_rounded,
            'الرئيسية',
            0,
          ),
          _buildDrawerItem(
            theme,
            Icons.menu_book_rounded,
            'القراءة',
            1,
          ),
          _buildDrawerItem(
            theme,
            Icons.format_quote_rounded,
            'الأذكار',
            2,
          ),
          _buildDrawerItem(
            theme,
            Icons.bar_chart_rounded,
            'الإحصائيات',
            3,
          ),
          Divider(color: theme.dividerColor.withOpacity(0.3)),
          ListTile(
            leading: Icon(Icons.calendar_today_rounded,
                color: theme.colorScheme.primary),
            title: const Text('إعداد خطة'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/plan');
            },
          ),
          ListTile(
            leading:
                Icon(Icons.settings_rounded, color: theme.colorScheme.primary),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EnhancedSettingsScreen(),
                ),
              );
            },
          ),
          Divider(color: theme.dividerColor.withOpacity(0.3)),
          ListTile(
            leading: Icon(Icons.info_outline_rounded,
                color: theme.colorScheme.primary),
            title: const Text('عن التطبيق'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(ThemeData theme) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Consumer2<ProfileProvider, GamificationProvider>(
        builder: (context, profileProvider, gamProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38, width: 2),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profileProvider.profile?.name ?? 'ختمتي',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      gamProvider.currentLevel.nameAr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${gamProvider.totalPoints} نقطة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(
      ThemeData theme, IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showAboutDialog() {
    final theme = Theme.of(context);
    showAboutDialog(
      context: context,
      applicationName: 'ختمتي',
      applicationVersion: '3.0.0',
      applicationIcon: Icon(
        Icons.menu_book_rounded,
        size: 48,
        color: theme.colorScheme.primary,
      ),
      applicationLegalese:
          'تم التطوير بواسطة: خالد سعد\n\u00A9 2026 جميع الحقوق محفوظة',
      children: const [
        SizedBox(height: 16),
        Text(
          'تطبيق متكامل لتتبع قراءة القرآن الكريم والأذكار اليومية',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 16),
        Text(
          'المميزات في النسخة 3.0:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('\u2713 نظام تحفيز ونقاط'),
        Text('\u2713 الوضع الداكن'),
        Text('\u2713 تصميم محسّن بالكامل'),
        Text('\u2713 نظام تنبيهات متقدم'),
        Text('\u2713 تتبع الأذكار المخصصة'),
        Text('\u2713 التفسير الميسر'),
        SizedBox(height: 16),
        Text(
          'نسأل الله أن يتقبل منا ومنكم صالح الأعمال',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

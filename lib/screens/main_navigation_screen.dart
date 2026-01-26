import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'reading_screen.dart';
import 'dhikr_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

/// الشاشة الرئيسية مع التنقل السفلي والقائمة الجانبية
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ReadingScreen(),
    DhikrScreen(),
    StatisticsScreen(),
  ];

  final List<String> _titles = const [
    'ختمتي',
    'القراءة',
    'الأذكار',
    'الإحصائيات',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'القراءة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'الأذكار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'الإحصائيات',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'ختمتي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                  ),
                ),
                Text(
                  'رفيقك في رحلة القرآن',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF1B5E20)),
            title: const Text('الرئيسية'),
            selected: _selectedIndex == 0,
            onTap: () {
              setState(() {
                _selectedIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book, color: Color(0xFF1B5E20)),
            title: const Text('القراءة'),
            selected: _selectedIndex == 1,
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.format_quote, color: Color(0xFF1B5E20)),
            title: const Text('الأذكار'),
            selected: _selectedIndex == 2,
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: Color(0xFF1B5E20)),
            title: const Text('الإحصائيات'),
            selected: _selectedIndex == 3,
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Color(0xFF1B5E20)),
            title: const Text('إعداد خطة'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/plan');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF1B5E20)),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF1B5E20)),
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

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'ختمتي',
      applicationVersion: '2.0.0',
      applicationIcon: const Icon(
        Icons.menu_book,
        size: 48,
        color: Color(0xFF1B5E20),
      ),
      applicationLegalese:
          'تم التطوير بواسطة: خالد سعد\n© 2026 جميع الحقوق محفوظة',
      children: const [
        SizedBox(height: 16),
        Text(
          'تطبيق متكامل لتتبع قراءة القرآن الكريم والأذكار اليومية',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 16),
        Text(
          'المميزات في النسخة 2.0:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('✓ نظام تنبيهات متقدم'),
        Text('✓ مواقيت الصلاة'),
        Text('✓ تتبع الأذكار المخصصة'),
        Text('✓ التفسير الميسر'),
        Text('✓ تنبيهات الورد القرآني'),
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

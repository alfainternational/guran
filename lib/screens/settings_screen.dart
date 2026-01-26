import 'package:flutter/material.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('التنبيهات'),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('إعدادات التنبيهات'),
            subtitle: const Text('أوقات الصلاة، الأذكار، والورد اليومي'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader('المظهر واللغة'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('السمة'),
            trailing: const Text('أخضر إسلامي'),
            onTap: () {
              // تغيير السمة
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('اللغة'),
            trailing: const Text('العربية'),
            onTap: () {
              // تغيير اللغة
            },
          ),
          const Divider(),
          _buildSectionHeader('عن التطبيق'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('نسخة التطبيق'),
            trailing: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('تقييم التطبيق'),
            onTap: () {
              // فتح المتجر للتقييم
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('مشاركة التطبيق'),
            onTap: () {
              // مشاركة التطبيق مع الآخرين
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1B5E20),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  Gender _selectedGender = Gender.male;
  int _currentStep = 0;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              _buildHeader(),
              const SizedBox(height: 48),
              Expanded(
                child: _buildStepContent(),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title = '';
    String subtitle = '';

    if (_currentStep == 0) {
      title = 'أهلاً بك في ختمتي';
      subtitle = 'دعنا نساعدك في تنظيم وقتك مع القرآن الكريم والأذكار.';
    } else if (_currentStep == 1) {
      title = 'من أنت؟';
      subtitle = 'نود التعرف عليك لتقديم تجربة مخصصة لك.';
    }

    return Column(
      children: [
        Icon(
          _currentStep == 0 ? Icons.menu_book : Icons.person_outline,
          size: 80,
          color: const Color(0xFF1B5E20),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    if (_currentStep == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFeatureItem(Icons.auto_graph, 'تتبع تقدمك في القراءة يومياً.'),
          _buildFeatureItem(
              Icons.notifications_active, 'تنبيهات مخصصة للأذكار والورد.'),
          _buildFeatureItem(
              Icons.emoji_events, 'أوسمة وجوائز تحفيزية عند الإنجاز.'),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'الاسم',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ageController,
            decoration: const InputDecoration(
              labelText: 'العمر',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.cake),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          const Text('الجنس',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGenderOption(Gender.male, 'ذكر', Icons.male),
              const SizedBox(width: 20),
              _buildGenderOption(Gender.female, 'أنثى', Icons.female),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE8F5E9),
            child: Icon(icon, color: const Color(0xFF1B5E20)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildGenderOption(Gender gender, String label, IconData icon) {
    final isSelected = _selectedGender == gender;
    return InkWell(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B5E20) : Colors.transparent,
          border: Border.all(color: const Color(0xFF1B5E20)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : const Color(0xFF1B5E20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _onNext,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B5E20),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              _currentStep == 0 ? 'لنبدأ' : 'إتمام الإعداد',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
    );
  }

  void _onNext() {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    } else {
      _saveAndFinish();
    }
  }

  Future<void> _saveAndFinish() async {
    final name = _nameController.text.trim();
    final ageStr = _ageController.text.trim();

    if (name.isEmpty || ageStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إكمال كافة البيانات')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final age = int.tryParse(ageStr) ?? 20;

      final profile = UserProfile(
        name: name,
        age: age,
        gender: _selectedGender,
      );

      final error = await context.read<ProfileProvider>().saveProfile(profile);

      if (error == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل حفظ البيانات: $error')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ غير متوقع: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

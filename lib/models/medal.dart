import 'package:flutter/material.dart';

enum MedalTier { bronze, silver, gold, diamond }

class Medal {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final MedalTier tier;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Medal({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tier,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tier': tier.toString(),
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }
}

class MedalService {
  static List<Medal> getInitialMedals() {
    return [
      Medal(
        id: 'streak_3',
        title: 'بداية القوة',
        description: 'التزام لـ 3 أيام متتالية',
        icon: Icons.flash_on,
        tier: MedalTier.bronze,
      ),
      Medal(
        id: 'streak_7',
        title: 'المثابر',
        description: 'التزام لـ 7 أيام متتالية',
        icon: Icons.whatshot,
        tier: MedalTier.silver,
      ),
      Medal(
        id: 'first_juz',
        title: 'الخطوة الأولى',
        description: 'إكمال الجزء الأول من القرآن',
        icon: Icons.auto_stories,
        tier: MedalTier.bronze,
      ),
      Medal(
        id: 'half_quran',
        title: 'نصف الدرب',
        description: 'إكمال 15 جزءاً من القرآن',
        icon: Icons.star,
        tier: MedalTier.gold,
      ),
      Medal(
        id: 'complete_quran',
        title: 'الخاتم',
        description: 'ختم القرآن الكريم كاملاً',
        icon: Icons.emoji_events,
        tier: MedalTier.diamond,
      ),
    ];
  }

  static Color getTierColor(MedalTier tier) {
    switch (tier) {
      case MedalTier.bronze:
        return Colors.orange[800]!;
      case MedalTier.silver:
        return Colors.grey[600]!;
      case MedalTier.gold:
        return Colors.amber[700]!;
      case MedalTier.diamond:
        return Colors.cyan[700]!;
    }
  }
}

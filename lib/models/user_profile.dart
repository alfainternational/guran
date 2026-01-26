enum Gender { male, female, other }

class UserProfile {
  final String name;
  final int age;
  final Gender gender;
  final DateTime joinedDate;
  final DateTime lastOpenDate;
  final int consecutiveDays;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    DateTime? joinedDate,
    DateTime? lastOpenDate,
    this.consecutiveDays = 1,
    this.unlockedMedalIds = const [],
  })  : joinedDate = joinedDate ?? DateTime.now(),
        lastOpenDate = lastOpenDate ?? DateTime.now();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      age: json['age'] as int,
      gender: Gender.values.firstWhere(
        (e) => e.toString() == json['gender'],
        orElse: () => Gender.male,
      ),
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      lastOpenDate: json['lastOpenDate'] != null
          ? DateTime.parse(json['lastOpenDate'] as String)
          : DateTime.now(),
      consecutiveDays: json['consecutiveDays'] as int? ?? 1,
      unlockedMedalIds: List<String>.from(json['unlockedMedalIds'] ?? []),
    );
  }

  final List<String> unlockedMedalIds;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender.toString(),
      'joinedDate': joinedDate.toIso8601String(),
      'lastOpenDate': lastOpenDate.toIso8601String(),
      'consecutiveDays': consecutiveDays,
      'unlockedMedalIds': unlockedMedalIds,
    };
  }
}

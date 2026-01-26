/// نموذج العلامة المرجعية
class Bookmark {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final int? page;
  final String? note;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    this.page,
    this.note,
    required this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as int,
      surahNumber: json['surah_number'] as int,
      ayahNumber: json['ayah_number'] as int,
      page: json['page'] as int?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'page': page,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// موقع القراءة الأخير
class LastReadPosition {
  final int surahNumber;
  final int ayahNumber;
  final int? page;
  final DateTime updatedAt;

  LastReadPosition({
    required this.surahNumber,
    required this.ayahNumber,
    this.page,
    required this.updatedAt,
  });

  factory LastReadPosition.fromJson(Map<String, dynamic> json) {
    return LastReadPosition(
      surahNumber: json['surah_number'] as int,
      ayahNumber: json['ayah_number'] as int,
      page: json['page'] as int?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'page': page,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

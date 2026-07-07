import 'dart:convert';

/// Matches your file: lib/model/check_in_model.dart
class CheckIn {
  final String id;
  final String note;
  final String imagePath; // permanent path inside app documents dir
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime createdAt;

  const CheckIn({
    required this.id,
    required this.note,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.createdAt,
  });

  // ── JSON serialisation ───────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'id': id,
        'note': note,
        'imagePath': imagePath,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CheckIn.fromMap(Map<String, dynamic> map) => CheckIn(
        id: map['id'] as String,
        note: map['note'] as String,
        imagePath: map['imagePath'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        accuracy: (map['accuracy'] as num).toDouble(),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  String toJson() => json.encode(toMap());

  factory CheckIn.fromJson(String source) =>
      CheckIn.fromMap(json.decode(source) as Map<String, dynamic>);
}
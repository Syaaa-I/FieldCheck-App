import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/check_in_model.dart';


class StorageService {
  static const String _key = 'fieldcheck_records';

  // Read

  Future<List<CheckIn>> getCheckIns() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((e) => CheckIn.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // Write

  /// Inserts newest record at the top of the list.
  Future<void> saveCheckIn(CheckIn checkIn) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getCheckIns();
    existing.insert(0, checkIn);
    await prefs.setString(
      _key,
      json.encode(existing.map((c) => c.toMap()).toList()),
    );
  }

  // Delete

  Future<void> deleteCheckIn(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getCheckIns();
    existing.removeWhere((c) => c.id == id);
    await prefs.setString(
      _key,
      json.encode(existing.map((c) => c.toMap()).toList()),
    );
  }
}
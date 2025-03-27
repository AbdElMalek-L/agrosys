import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class RecentActivityStorage {
  static const String _storageKey = 'recent_activities';

  static Future<List<Map<String, String>>> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedActivities = prefs.getString(_storageKey);
    if (storedActivities != null) {
      return List<Map<String, String>>.from(json.decode(storedActivities));
    }
    return [];
  }

  static Future<void> addActivity(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> activities = await loadActivities();

    final newActivity = {
      'title': title,
      'subtitle': subtitle,
      'icon': icon.codePoint.toString(),
      'color': color.value.toString(),
    };

    activities.insert(0, newActivity);
    await prefs.setString(_storageKey, json.encode(activities));
  }
}

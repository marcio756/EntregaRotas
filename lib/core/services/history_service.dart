// Ficheiro: lib/core/services/history_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Handles localized file I/O for logging historical route performance summaries.
/// Isolates logging architecture from Isar lifecycle to avoid schema compilation issues.
class HistoryService {
  
  Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/delivery_history_logs.json');
  }

  /// Appends a structured snapshot of a completed route day into the JSON database.
  Future<void> saveDaySummary({
    required String dateStr,
    required String routeName,
    required Map<String, int> delivered,
    required Map<String, int> notDelivered,
    required Map<String, int> extra,
  }) async {
    final file = await _getLogFile();
    List<dynamic> logs = [];

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        logs = jsonDecode(content) as List<dynamic>;
      } catch (_) {
        logs = [];
      }
    }

    final newEntry = {
      'date': dateStr,
      'routeName': routeName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'delivered': delivered,
      'notDelivered': notDelivered,
      'extra': extra,
    };

    // Remove duplicates for the same day/route combination if re-saved
    logs.removeWhere((entry) => entry['date'] == dateStr && entry['routeName'] == routeName);
    logs.add(newEntry);

    await file.writeAsString(jsonEncode(logs));
  }

  /// Fetches all logged historical summaries.
  Future<List<Map<String, dynamic>>> fetchAllLogs() async {
    final file = await _getLogFile();
    if (!await file.exists()) return [];

    try {
      final content = await file.readAsString();
      final list = jsonDecode(content) as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList()
        ..sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
    } catch (_) {
      return [];
    }
  }
}
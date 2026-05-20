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
  /// Intelligently groups multiple routes completed on the same date.
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

    int existingIndex = logs.indexWhere((entry) => entry['date'] == dateStr);

    if (existingIndex >= 0) {
      // OTIMIZAÇÃO: Fundir com o dia existente para agrupar tudo
      final existingEntry = logs[existingIndex];
      
      List<String> routeNames = [];
      if (existingEntry['routeNames'] != null) {
        routeNames = List<String>.from(existingEntry['routeNames']);
      } else if (existingEntry['routeName'] != null) {
        // Migração suave de dados antigos
        routeNames = [existingEntry['routeName'] as String];
      }

      if (!routeNames.contains(routeName)) {
        routeNames.add(routeName);
      }

      // Função utilitária para somar as quantidades de dois Maps
      Map<String, int> mergeMaps(Map<String, dynamic> map1, Map<String, int> map2) {
        final result = Map<String, int>.from(map1);
        map2.forEach((key, value) {
          result[key] = (result[key] ?? 0) + value;
        });
        return result;
      }

      logs[existingIndex] = {
        'date': dateStr,
        'routeNames': routeNames,
        'timestamp': existingEntry['timestamp'],
        'delivered': mergeMaps(Map<String, dynamic>.from(existingEntry['delivered'] ?? {}), delivered),
        'notDelivered': mergeMaps(Map<String, dynamic>.from(existingEntry['notDelivered'] ?? {}), notDelivered),
        'extra': mergeMaps(Map<String, dynamic>.from(existingEntry['extra'] ?? {}), extra),
      };
    } else {
      // Nova entrada para um dia novo
      logs.add({
        'date': dateStr,
        'routeNames': [routeName],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'delivered': delivered,
        'notDelivered': notDelivered,
        'extra': extra,
      });
    }

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
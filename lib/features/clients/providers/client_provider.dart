import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../core/database/collections/client_point_collection.dart';
import 'package:isar/isar.dart';

/// Provider responsible for managing the state of Client Points.
final clientListProvider = StateNotifierProvider<ClientNotifier, List<ClientPoint>>((ref) {
  return ClientNotifier();
});

class ClientNotifier extends StateNotifier<List<ClientPoint>> {
  ClientNotifier() : super([]) {
    _loadClients();
  }

  Future<void> _loadClients() async {
    final isar = await isarService.db;
    state = await isar.clientPoints.where().findAll();
  }

  // A função de adicionar cliente será implementada no formulário de GPS futuramente.
}
// Ficheiro: lib/features/clients/providers/client_provider.dart

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

  /// Saves a new client and their default order to the Isar database
  Future<void> addClient(ClientPoint client) async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.clientPoints.put(client);
    });
    await _loadClients();
  }

  /// Deletes a client from the Isar database
  /// @param {int} id - The unique identifier of the client to delete
  Future<void> deleteClient(int id) async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.clientPoints.delete(id);
    });
    await _loadClients();
  }
}
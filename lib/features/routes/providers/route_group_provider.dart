// Ficheiro: lib/features/routes/providers/route_group_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../core/database/collections/route_group_collection.dart';
import '../../../core/database/collections/route_collection.dart';
import 'package:isar/isar.dart';

final routeGroupListProvider = StateNotifierProvider<RouteGroupNotifier, List<RouteGroup>>((ref) {
  return RouteGroupNotifier();
});

class RouteGroupNotifier extends StateNotifier<List<RouteGroup>> {
  RouteGroupNotifier() : super([]) {
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final isar = await isarService.db;
    state = await isar.routeGroups.where().findAll();
    
    // Assegurar que as ligações (IsarLinks) às rotas são carregadas para a memória
    for (var group in state) {
      await group.routes.load();
    }
    
    // Forçar atualização do state para garantir reatividade
    state = List.from(state);
  }

  Future<void> addGroup(String name, List<DeliveryRoute> selectedRoutes) async {
    final isar = await isarService.db;
    final newGroup = RouteGroup()..name = name;
    
    await isar.writeTxn(() async {
      await isar.routeGroups.put(newGroup);
      newGroup.routes.addAll(selectedRoutes);
      await newGroup.routes.save();
    });
    await _loadGroups();
  }

  /// Permite atualizar as propriedades e as ligações filhas de um Grupo existente.
  Future<void> updateGroup(int groupId, String newName, List<DeliveryRoute> selectedRoutes) async {
    final isar = await isarService.db;
    final group = await isar.routeGroups.get(groupId);
    
    if (group != null) {
      group.name = newName;
      
      await isar.writeTxn(() async {
        // Grava a atualização do nome
        await isar.routeGroups.put(group);
        
        // Substituição das relações físicas (IsarLinks) de forma segura
        group.routes.clear(); 
        group.routes.addAll(selectedRoutes);
        await group.routes.save();
      });
      
      await _loadGroups();
    }
  }

  Future<void> deleteGroup(int groupId) async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.routeGroups.delete(groupId);
    });
    await _loadGroups();
  }
}
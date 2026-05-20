// Ficheiro: lib/features/routes/providers/route_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../../core/database/collections/route_stop_collection.dart';
import 'package:isar/isar.dart';

final routeListProvider = StateNotifierProvider<RouteNotifier, List<DeliveryRoute>>((ref) {
  return RouteNotifier();
});

class RouteNotifier extends StateNotifier<List<DeliveryRoute>> {
  RouteNotifier() : super([]) {
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final isar = await isarService.db;
    state = await isar.deliveryRoutes.where().findAll();
  }

  Future<void> addRoute(String name) async {
    final isar = await isarService.db;
    final newRoute = DeliveryRoute()..name = name;
    
    await isar.writeTxn(() async {
      await isar.deliveryRoutes.put(newRoute);
    });
    await _loadRoutes();
  }

  /// Modifies the label representation of a localized route entity.
  /// Assures changes are instantly broad-casted to the global state stream.
  Future<void> updateRoute(int routeId, String newName) async {
    final isar = await isarService.db;
    final route = await isar.deliveryRoutes.get(routeId);
    
    if (route != null) {
      route.name = newName;
      await isar.writeTxn(() async {
        await isar.deliveryRoutes.put(route);
      });
      await _loadRoutes();
    }
  }

  /// Performs a cascade database deletion of a specific route.
  /// Purges all corresponding RouteStop links first to avoid breaking offline referential integrity.
  Future<void> deleteRoute(int routeId) async {
    final isar = await isarService.db;
    
    await isar.writeTxn(() async {
      // Fetch all global stops and filter manually due to linked reference limitations in Isar
      final allStops = await isar.routeStops.where().findAll();
      for (var stop in allStops) {
        await stop.route.load();
        if (stop.route.value?.id == routeId) {
          await isar.routeStops.delete(stop.id);
        }
      }
      
      // Complete transaction by wiping the primary route entry
      await isar.deliveryRoutes.delete(routeId);
    });
    await _loadRoutes();
  }
}
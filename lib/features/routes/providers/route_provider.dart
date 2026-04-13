import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../core/database/collections/route_collection.dart';
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
}
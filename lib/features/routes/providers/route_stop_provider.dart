// Ficheiro: lib/features/routes/providers/route_stop_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../core/database/collections/route_stop_collection.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../../core/database/collections/client_point_collection.dart';
import 'package:isar/isar.dart';

/// Provider that fetches stops for a specific route ID.
final routeStopsProvider = StateNotifierProvider.family<RouteStopNotifier, List<RouteStop>, int>((ref, routeId) {
  return RouteStopNotifier(routeId);
});

class RouteStopNotifier extends StateNotifier<List<RouteStop>> {
  final int routeId;

  RouteStopNotifier(this.routeId) : super([]) {
    _loadStops();
  }

  Future<void> _loadStops() async {
    final isar = await isarService.db;
    // Uses Isar's relational querying to find stops belonging to this specific route
    final stops = await isar.routeStops
        .filter()
        .route((q) => q.idEqualTo(routeId))
        .sortByStopOrder()
        .findAll();
        
    // Load relational data (Client details) into memory for the UI
    for (var stop in stops) {
      await stop.clientPoint.load();
    }
    state = stops;
  }

  /// Creates a relational link between a Route and a ClientPoint
  Future<void> addClientToRoute(DeliveryRoute route, ClientPoint client, List<String> products) async {
    final isar = await isarService.db;
    
    final newStop = RouteStop()
      ..stopOrder = state.length // Adds to the end of the list
      ..productsToDeliver = products
      ..isDelivered = false;

    await isar.writeTxn(() async {
      await isar.routeStops.put(newStop);
      
      // Save relational links
      newStop.route.value = route;
      newStop.clientPoint.value = client;
      
      await newStop.route.save();
      await newStop.clientPoint.save();
    });
    
    await _loadStops();
  }

  /// Toggles the delivery status of a specific stop and persists it to the local database.
  /// Used for marking a delivery as complete or performing an 'Undo' action.
  /// 
  /// @param {int} stopId - The unique identifier of the route stop.
  /// @param {bool} status - The new delivery status to apply (true for delivered, false for undo).
  Future<void> toggleDeliveryStatus(int stopId, bool status) async {
    final isar = await isarService.db;
    final stop = await isar.routeStops.get(stopId);
    
    if (stop != null) {
      stop.isDelivered = status;
      await isar.writeTxn(() async {
        await isar.routeStops.put(stop);
      });
      await _loadStops(); // Triggers a state update for the UI to reflect changes
    }
  }
}
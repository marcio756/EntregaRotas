import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../core/database/collections/route_stop_collection.dart';
import '../../../core/database/collections/route_collection.dart';
import 'package:isar/isar.dart';

/// Provider that fetches and manages orders (stops) for a specific route ID.
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
    
    final allStops = await isar.routeStops.where().sortByStopOrder().findAll();
    final List<RouteStop> strictRouteStops = [];
    
    for (var stop in allStops) {
      await stop.route.load();
      if (stop.route.value?.id == routeId) {
        strictRouteStops.add(stop);
      }
    }
    
    state = strictRouteStops;
  }

  /// Creates a self-contained Order (RouteStop) and links it to the Route
  Future<void> addOrderToRoute({
    required DeliveryRoute route,
    required String orderName,
    required String? notes,
    required double latitude,
    required double longitude,
    required String captureMethod,
    required String? imagePath,
    required List<String> products,
  }) async {
    final isar = await isarService.db;
    
    final newOrder = RouteStop()
      ..orderName = orderName
      ..notes = notes
      ..latitude = latitude
      ..longitude = longitude
      ..locationCaptureMethod = captureMethod
      ..localImagePath = imagePath
      ..stopOrder = state.length
      ..productsToDeliver = products
      ..isDelivered = false;

    await isar.writeTxn(() async {
      await isar.routeStops.put(newOrder);
      newOrder.route.value = route;
      await newOrder.route.save();
    });
    
    await _loadStops();
  }

  /// Updates an existing Order (RouteStop) attributes in the local database.
  /// 
  /// @param {int} stopId - The unique Isar identifier of the order to edit.
  Future<void> updateOrderInRoute({
    required int stopId,
    required String orderName,
    required String? notes,
    required double latitude,
    required double longitude,
    required String captureMethod,
    required String? imagePath,
    required List<String> products,
  }) async {
    final isar = await isarService.db;
    final existingOrder = await isar.routeStops.get(stopId);
    
    if (existingOrder != null) {
      existingOrder.orderName = orderName;
      existingOrder.notes = notes;
      existingOrder.latitude = latitude;
      existingOrder.longitude = longitude;
      existingOrder.locationCaptureMethod = captureMethod;
      existingOrder.localImagePath = imagePath;
      existingOrder.productsToDeliver = products;

      await isar.writeTxn(() async {
        await isar.routeStops.put(existingOrder);
      });
      await _loadStops();
    }
  }

  /// Toggles the delivery status of a specific order
  Future<void> toggleDeliveryStatus(int stopId, bool status) async {
    final isar = await isarService.db;
    final stop = await isar.routeStops.get(stopId);
    
    if (stop != null) {
      stop.isDelivered = status;
      await isar.writeTxn(() async {
        await isar.routeStops.put(stop);
      });
      await _loadStops(); 
    }
  }

  /// Removes an order completely from the route
  Future<void> deleteOrder(int stopId) async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.routeStops.delete(stopId);
    });
    await _loadStops();
  }

  /// Updates the sequence order of the stops (Drag and Drop)
  Future<void> updateStopsOrder(List<RouteStop> reorderedStops) async {
    final isar = await isarService.db;
    
    state = reorderedStops;

    await isar.writeTxn(() async {
      for (int i = 0; i < reorderedStops.length; i++) {
        final stop = reorderedStops[i];
        stop.stopOrder = i;
        await isar.routeStops.put(stop);
      }
    });
  }
}
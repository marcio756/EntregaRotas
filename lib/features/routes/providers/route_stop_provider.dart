// Ficheiro: lib/features/routes/providers/route_stop_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../core/database/collections/route_stop_collection.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../../core/utils/geo_utils.dart';
import 'package:isar/isar.dart';

/// Provider that fetches and manages orders (stops) for a specific route ID.
final routeStopsProvider = StateNotifierProvider.family<RouteStopNotifier, List<RouteStop>, int>((ref, routeId) {
  return RouteStopNotifier(routeId);
});

/// Computes the aggregated sum of all products required for a specific delivery route.
/// Ensures business logic (aggregation) is completely segregated from the UI layer.
final routeLoadSummaryProvider = Provider.family<Map<String, int>, int>((ref, routeId) {
  final stops = ref.watch(routeStopsProvider(routeId));
  final Map<String, int> loadTotals = {};

  for (var stop in stops) {
    for (var productStr in stop.productsToDeliver) {
      final parts = productStr.split('x ');
      if (parts.length >= 2) {
        final qty = int.tryParse(parts[0]) ?? 0;
        final remainder = parts[1].trim();
        
        String pureProductInfo = remainder;
        if (remainder.contains(' | orig: ')) {
          pureProductInfo = remainder.split(' | orig: ')[0].trim();
        }
        
        final pureName = pureProductInfo.split(' (')[0].trim();
        
        if (qty > 0) {
          loadTotals[pureName] = (loadTotals[pureName] ?? 0) + qty;
        }
      }
    }
  }
  return loadTotals;
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

  Future<void> adjustProductQuantity(int stopId, int productIndex, bool isIncrement) async {
    final isar = await isarService.db;
    final stop = await isar.routeStops.get(stopId);
    
    if (stop != null && productIndex < stop.productsToDeliver.length) {
      final List<String> updatedProducts = List.from(stop.productsToDeliver);
      final String currentLine = updatedProducts[productIndex];
      
      final parts = currentLine.split('x ');
      if (parts.length == 2) {
        int currentQty = int.tryParse(parts[0]) ?? 0;
        final remainder = parts[1];
        
        int originalQty = currentQty;
        String pureProductInfo = remainder;
        
        if (remainder.contains(' | orig: ')) {
          final subParts = remainder.split(' | orig: ');
          pureProductInfo = subParts[0];
          originalQty = int.tryParse(subParts[1]) ?? currentQty;
        }
        
        if (isIncrement) {
          currentQty++;
        } else {
          if (currentQty > 0) currentQty--;
        }
        
        if (currentQty == originalQty) {
          updatedProducts[productIndex] = '${currentQty}x $pureProductInfo';
        } else {
          updatedProducts[productIndex] = '${currentQty}x $pureProductInfo | orig: $originalQty';
        }
        
        stop.productsToDeliver = updatedProducts;
        await isar.writeTxn(() async {
          await isar.routeStops.put(stop);
        });
        await _loadStops();
      }
    }
  }

  Future<void> resetRouteCompletion() async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      for (var stop in state) {
        stop.isDelivered = false;
        
        final List<String> cleanedProducts = [];
        for (var productStr in stop.productsToDeliver) {
          if (productStr.contains(' | orig: ')) {
            final parts = productStr.split('x ');
            if (parts.length == 2) {
              final remainder = parts[1];
              final subParts = remainder.split(' | orig: ');
              final pureProductInfo = subParts[0];
              final origQty = subParts[1];
              cleanedProducts.add('${origQty}x $pureProductInfo');
            } else {
              cleanedProducts.add(productStr);
            }
          } else {
            cleanedProducts.add(productStr);
          }
        }
        stop.productsToDeliver = cleanedProducts;
        await isar.routeStops.put(stop);
      }
    });
    await _loadStops();
  }

  Future<void> deleteOrder(int stopId) async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.routeStops.delete(stopId);
    });
    await _loadStops();
  }

  Future<void> restoreOrder(RouteStop order) async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.routeStops.put(order);
      await order.route.save();
    });
    await _loadStops();
  }

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

  /// Optimizes the remaining pending stops using a Greedy TSP algorithm (closest neighbor)
  /// starting from the provided GPS location. Updates the sequence locally.
  Future<void> optimizePendingStops(double currentLat, double currentLon) async {
    final isar = await isarService.db;
    
    final pending = state.where((s) => !s.isDelivered).toList();
    final delivered = state.where((s) => s.isDelivered).toList();
    
    if (pending.isEmpty) return;

    List<RouteStop> optimizedPending = [];
    double lastLat = currentLat;
    double lastLon = currentLon;
    List<RouteStop> unvisited = List.from(pending);

    // Greedy sorting: always find the closest next point
    while (unvisited.isNotEmpty) {
      RouteStop? nearestStop;
      double minDistance = double.infinity;

      for (var stop in unvisited) {
        final dist = GeoUtils.calculateDistance(lastLat, lastLon, stop.latitude, stop.longitude);
        if (dist < minDistance) {
          minDistance = dist;
          nearestStop = stop;
        }
      }

      if (nearestStop != null) {
        optimizedPending.add(nearestStop);
        unvisited.remove(nearestStop);
        lastLat = nearestStop.latitude;
        lastLon = nearestStop.longitude;
      }
    }

    final newOrder = [...delivered, ...optimizedPending];
    state = newOrder;

    // Persist optimized order to Isar
    await isar.writeTxn(() async {
      for (int i = 0; i < newOrder.length; i++) {
        final stop = newOrder[i];
        stop.stopOrder = i;
        await isar.routeStops.put(stop);
      }
    });
  }
}
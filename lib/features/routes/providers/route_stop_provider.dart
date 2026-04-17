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
    
    // Abordagem à prova de falhas: Busca todas as paragens e filtra estritamente na memória.
    // Isto contorna potenciais bugs do Isar ao usar filtros de links gerados automaticamente.
    final allStops = await isar.routeStops.where().sortByStopOrder().findAll();
    
    final List<RouteStop> strictRouteStops = [];
    
    for (var stop in allStops) {
      await stop.route.load(); // Carrega a referência da rota associada
      
      // Validação Estrita: Só entra na lista se o ID da Rota bater certo!
      if (stop.route.value?.id == routeId) {
        await stop.clientPoint.load(); // Carrega os detalhes do cliente
        strictRouteStops.add(stop);
      }
    }
    
    state = strictRouteStops;
  }

  /// Creates a relational link between a Route and a ClientPoint
  Future<void> addClientToRoute(DeliveryRoute route, ClientPoint client, List<String> products) async {
    final isar = await isarService.db;
    
    final newStop = RouteStop()
      ..stopOrder = state.length
      ..productsToDeliver = products
      ..isDelivered = false;

    await isar.writeTxn(() async {
      await isar.routeStops.put(newStop);
      
      newStop.route.value = route;
      newStop.clientPoint.value = client;
      
      await newStop.route.save();
      await newStop.clientPoint.save();
    });
    
    await _loadStops();
  }

  /// Toggles the delivery status of a specific stop and persists it to the local database.
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
}
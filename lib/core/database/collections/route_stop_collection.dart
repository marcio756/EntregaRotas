import 'package:isar/isar.dart';
import 'client_point_collection.dart';
import 'route_collection.dart';

part 'route_stop_collection.g.dart';

/// Represents a specific stop in a route.
/// Architecturally satisfies the requirement: "The same client point can be 
/// allocated to multiple days with different quantities or products".
@collection
class RouteStop {
  Id id = Isar.autoIncrement;

  /// Relational link to the specific Route (e.g., Monday)
  final route = IsarLink<DeliveryRoute>();

  /// Relational link to the physical Client Point (GPS and Address)
  final clientPoint = IsarLink<ClientPoint>();

  /// Display order in the route (manual sorting or proximity based)
  late int stopOrder;

  /// Summary of products and quantities for this specific day/stop.
  /// (e.g., ["2x Pão de Forma", "10x Carcaça"]).
  late List<String> productsToDeliver;
  
  /// Marks if the delivery was completed in the current run.
  bool isDelivered = false;
}
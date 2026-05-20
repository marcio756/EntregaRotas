// Ficheiro: lib/core/database/collections/route_group_collection.dart
import 'package:isar/isar.dart';
import 'route_collection.dart';

part 'route_group_collection.g.dart';

/// Represents a Group of Delivery Routes (e.g., 'Domingo' clustering Route 1, 2, 3).
/// Stored offline for fast access and composite load sheets.
@collection
class RouteGroup {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name; // e.g., "Domingo"

  /// Relational link to multiple individual delivery routes.
  final routes = IsarLinks<DeliveryRoute>();
}
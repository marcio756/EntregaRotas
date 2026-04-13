import 'package:isar/isar.dart';

part 'route_collection.g.dart';

/// Represents a Delivery Route (e.g., 'Rota de Segunda-feira').
/// Stored offline for fast access during the work shift.
@collection
class DeliveryRoute {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name; // e.g., "Rota de Segunda-feira"

  /// Indicates if this route is the currently active one for the day.
  bool isActive = false;
}
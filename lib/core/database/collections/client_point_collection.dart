import 'package:isar/isar.dart';

part 'client_point_collection.g.dart'; // Required for Isar code generation

/// Represents a physical delivery point (Client) with exact GPS coordinates.
/// Stored offline to ensure map and geofencing work without internet.
@collection
class ClientPoint {
  Id id = Isar.autoIncrement;

  late String clientName;

  String? contact;

  String? deliveryNotes;

  /// Latitude for exact Pinpoint and Geofencing (30m radius detection)
  late double latitude;

  /// Longitude for exact Pinpoint and Geofencing (30m radius detection)
  late double longitude;
}
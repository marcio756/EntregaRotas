import 'package:isar/isar.dart';

part 'client_point_collection.g.dart'; // Required for Isar code generation

/// Represents a physical delivery point (Client) with exact GPS coordinates.
/// Stored offline to ensure map and geofencing work without internet.
/// Updated to support rich media, physical addresses, and tracking of how the location was acquired.
@collection
class ClientPoint {
  Id id = Isar.autoIncrement;

  late String clientName;

  String? deliveryNotes;

  /// Latitude for exact Pinpoint and Geofencing (30m radius detection)
  late double latitude;

  /// Longitude for exact Pinpoint and Geofencing (30m radius detection)
  late double longitude;

  /// Formatted physical address of the client point.
  String? address;

  /// The method used to capture the location. 
  /// Expected values: 'GPS_AUTO', 'MANUAL_ENTRY', 'INTERACTIVE_MAP'.
  String? locationCaptureMethod;

  /// List of local file system paths pointing to photos of the client's location.
  /// Follows best practices by not bloating the DB with binary blob data.
  List<String> localImagePaths = [];

  /// Local file system path pointing to a captured Street View or Map screenshot.
  String? streetViewImagePath;

  /// Default order associated with this client upon creation
  /// (e.g., ["2x Pão de Forma", "10x Carcaça"]).
  List<String> defaultProducts = [];
}
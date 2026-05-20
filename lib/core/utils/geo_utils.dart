// Ficheiro: lib/core/utils/geo_utils.dart
import 'package:geolocator/geolocator.dart';

/// Utility class to abstract spatial and geographical calculations.
/// Segregating this logic ensures the UI and presentation layers remain oblivious to the underlying math, adhering to SRP.
class GeoUtils {
  /// Calculates the distance in meters between two geographical coordinates.
  /// 
  /// @param {double} startLat - Latitude of the origin point.
  /// @param {double} startLng - Longitude of the origin point.
  /// @param {double} endLat - Latitude of the destination point.
  /// @param {double} endLng - Longitude of the destination point.
  /// @returns {double} Distance in meters.
  static double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
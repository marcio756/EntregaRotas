import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'collections/product_collection.dart';
import 'collections/client_point_collection.dart';
import 'collections/route_collection.dart';
import 'collections/route_stop_collection.dart';

/// Manages the local Isar Database lifecycle.
/// Ensures that the offline-first architecture is robust and always available.
class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = _initDb();
  }

  /// Initializes the Isar database and registers all offline collections.
  Future<Isar> _initDb() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          ProductSchema, 
          ClientPointSchema,
          DeliveryRouteSchema,
          RouteStopSchema
        ],
        directory: dir.path,
        inspector: true, // Enables Isar Inspector for debugging in browser
      );
    }
    return Future.value(Isar.getInstance());
  }
}
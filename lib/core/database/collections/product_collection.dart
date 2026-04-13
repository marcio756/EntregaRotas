import 'package:isar/isar.dart';

part 'product_collection.g.dart';

/// Represents a Product in the catalog.
/// Only the name is mandatory for quick creation.
@collection
class Product {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  String? category;
  
  double? unitPrice;
  
  int? defaultQuantity;
}
import 'package:isar/isar.dart';

part 'product_collection.g.dart';

/// Represents a Product in the catalog.
@collection
class Product {
  Id id = Isar.autoIncrement;

  // CORREÇÃO: Índice Composto. Permite "Pão" (Trigo) e "Pão" (Centeio)
  @Index(unique: true, composite: [CompositeIndex('category')])
  late String name;

  String? category;
  
  double? unitPrice;
  
  int? defaultQuantity;
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../core/database/collections/product_collection.dart'; // Caminho de importação corrigido
import 'package:isar/isar.dart';

/// Provider that manages the list of products from the local database.
final productListProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});

/// Notifier responsible for Product CRUD operations with Isar.
/// Handles async transactions to prevent app crashes during saves.
class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier() : super([]) {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final isar = await isarService.db;
    state = await isar.products.where().findAll();
  }

  /// Saves a product to the database and updates the UI state.
  Future<void> addProduct(Product product) async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.products.put(product);
    });
    await _loadProducts(); // Refresh the list
  }
}
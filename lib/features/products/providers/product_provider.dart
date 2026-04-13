import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../core/database/collections/product_collection.dart';
import 'package:isar/isar.dart';

final productListProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier() : super([]) {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final isar = await isarService.db;
    state = await isar.products.where().findAll();
  }

  /// Guarda um novo produto ou atualiza um existente (Upsert).
  Future<void> saveProduct(Product product) async {
    final isar = await isarService.db;
    
    // Verificação inteligente de duplicados (Nome + Categoria)
    final query = isar.products.filter().nameEqualTo(product.name);
    final existingProduct = product.category == null 
        ? await query.categoryIsNull().findFirst()
        : await query.categoryEqualTo(product.category!).findFirst();

    // Se encontrou um produto igual, mas com um ID diferente (ou seja, não estamos a editar o próprio produto)
    if (existingProduct != null && existingProduct.id != product.id) {
      final catNome = product.category ?? 'Sem Categoria';
      throw Exception('Já existe "${product.name}" na categoria "$catNome".');
    }

    // Grava na base de dados (se o ID já existir, o Isar atualiza automaticamente)
    await isar.writeTxn(() async {
      await isar.products.put(product);
    });
    
    await _loadProducts(); // Atualiza a lista na UI
  }

  /// Elimina um produto da base de dados.
  Future<void> deleteProduct(int id) async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.products.delete(id);
    });
    await _loadProducts();
  }
}
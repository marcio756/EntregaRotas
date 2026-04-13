import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import 'product_form_screen.dart';
import '../../../core/database/collections/product_collection.dart';

class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key});

  void _confirmDelete(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar Produto?'),
        content: Text('Tem a certeza que deseja apagar "${product.name}" do catálogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              ref.read(productListProvider.notifier).deleteProduct(product.id);
              Navigator.pop(context);
            },
            child: const Text('APAGAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Produtos')),
      body: products.isEmpty
          ? const Center(child: Text('Nenhum produto registado.'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: const Icon(Icons.bakery_dining),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(product.category ?? 'Sem categoria'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão Editar
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductFormScreen(productToEdit: product),
                            ),
                          );
                        },
                      ),
                      // Botão Apagar
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        onPressed: () => _confirmDelete(context, ref, product),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProductFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../../../core/database/collections/product_collection.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? productToEdit; // Se for null cria, se tiver dados edita.

  const ProductFormScreen({super.key, this.productToEdit});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preenche os dados se estivermos em modo de Edição
    if (widget.productToEdit != null) {
      _nameController.text = widget.productToEdit!.name;
      _categoryController.text = widget.productToEdit!.category ?? '';
      _quantityController.text = (widget.productToEdit!.defaultQuantity ?? 0).toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final productName = _nameController.text.trim();
      
      final newProduct = Product()
        ..name = productName
        ..category = _categoryController.text.isEmpty ? null : _categoryController.text.trim()
        ..defaultQuantity = int.tryParse(_quantityController.text) ?? 0;

      // Se for edição, mantemos o ID original para o Isar sobrescrever
      if (widget.productToEdit != null) {
        newProduct.id = widget.productToEdit!.id;
      }

      try {
        await ref.read(productListProvider.notifier).saveProduct(newProduct);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Produto' : 'Criar Produto')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Produto (ex: Carcaça)*'),
                validator: (v) => v!.trim().isEmpty ? 'O nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoria/Tipo'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade por Defeito'),
                keyboardType: TextInputType.number,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(
                    isEditing ? 'ATUALIZAR PRODUTO' : 'GUARDAR PRODUTO', 
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
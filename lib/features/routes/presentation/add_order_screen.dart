import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../../core/database/collections/product_collection.dart';
import '../../../core/database/collections/route_stop_collection.dart';
import '../../../core/services/local_file_service.dart';
import '../../products/providers/product_provider.dart';
import '../providers/route_stop_provider.dart';
import 'interactive_map_picker_screen.dart'; 
import 'street_view_capture_screen.dart'; 

/// A dual-purpose screen that handles both creating a brand new order
/// or parsing and modifying an existing RouteStop object.
class AddOrderScreen extends ConsumerStatefulWidget {
  final DeliveryRoute activeRoute;
  final RouteStop? orderToEdit; // Optional object. If passed, triggers Edit Mode.

  const AddOrderScreen({super.key, required this.activeRoute, this.orderToEdit});

  @override
  ConsumerState<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends ConsumerState<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  
  LatLng? _capturedLocation;
  String _captureMethod = 'NONE';
  bool _isLocating = false;

  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();
  final LocalFileService _fileService = LocalFileService();

  final Map<int, int> _selectedQuantities = {};
  final List<Product> _addedProducts = [];

  @override
  void initState() {
    super.initState();
    _populateFieldsIfEditing();
  }

  /// Parses saved order data and fills the controllers if widget.orderToEdit is injected.
  void _populateFieldsIfEditing() {
    if (widget.orderToEdit != null) {
      _nameController.text = widget.orderToEdit!.orderName;
      _notesController.text = widget.orderToEdit!.notes ?? '';
      _capturedLocation = LatLng(widget.orderToEdit!.latitude, widget.orderToEdit!.longitude);
      _captureMethod = widget.orderToEdit!.locationCaptureMethod ?? 'INTERACTIVE_MAP';
      
      if (widget.orderToEdit!.localImagePath != null) {
        _capturedImage = File(widget.orderToEdit!.localImagePath!);
      }

      // Rebuild product associations dynamically from the current product catalog
      final catalog = ref.read(productListProvider);
      for (var summary in widget.orderToEdit!.productsToDeliver) {
        final parts = summary.split('x ');
        if (parts.length == 2) {
          final qty = int.tryParse(parts[0]) ?? 0;
          final productName = parts[1].trim();
          
          try {
            final targetProduct = catalog.firstWhere((p) => p.name == productName);
            _addedProducts.add(targetProduct);
            _selectedQuantities[targetProduct.id] = qty;
          } catch (_) {
            // Transient handling if a product was deleted from master catalog but remains on old log
            final runtimeProduct = Product()..id = productName.hashCode..name = productName;
            _addedProducts.add(runtimeProduct);
            _selectedQuantities[runtimeProduct.id] = qty;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _captureGPS() async {
    setState(() => _isLocating = true);
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _capturedLocation = LatLng(position.latitude, position.longitude);
        _captureMethod = 'GPS_AUTO';
        _isLocating = false;
      });
    } catch (_) {
      setState(() => _isLocating = false);
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<PickedLocationData>(
      MaterialPageRoute(builder: (context) => InteractiveMapPickerScreen(initialLocation: _capturedLocation)),
    );
    
    if (result != null) {
      setState(() {
        _capturedLocation = result.coordinates;
        _captureMethod = result.captureMethod;
      });
    }
  }

  Future<void> _openStreetViewCamera() async {
    if (_capturedLocation == null) return;
    
    final imagePath = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => StreetViewCaptureScreen(
          latitude: _capturedLocation!.latitude,
          longitude: _capturedLocation!.longitude,
        ),
      ),
    );
    
    if (imagePath != null) {
      setState(() {
        _capturedImage = File(imagePath);
      });
    }
  }

  Future<void> _takeNormalPhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (photo != null) {
      setState(() => _capturedImage = File(photo.path));
    }
  }

  void _showProductSelector(List<Product> catalog) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: catalog.length,
        itemBuilder: (context, index) {
          final prod = catalog[index];
          return ListTile(
            title: Text(prod.name),
            subtitle: Text(prod.category ?? 'Geral'),
            trailing: const Icon(Icons.add),
            onTap: () {
              setState(() {
                if (!_addedProducts.any((p) => p.id == prod.id)) {
                  _addedProducts.add(prod);
                  _selectedQuantities[prod.id] = prod.defaultQuantity ?? 1;
                }
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  Future<void> _saveOrder() async {
    if (_formKey.currentState!.validate()) {
      if (_capturedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, defina a localização do pedido.')));
        return;
      }
      if (_addedProducts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicione pelo menos um produto ao pedido.')));
        return;
      }

      String? finalImagePath = widget.orderToEdit?.localImagePath;
      if (_capturedImage != null && (widget.orderToEdit == null || _capturedImage!.path != widget.orderToEdit!.localImagePath)) {
        finalImagePath = await _fileService.saveImageLocally(_capturedImage!, prefix: 'pedido');
      }

      final List<String> productsSummary = [];
      for (var prod in _addedProducts) {
        final qty = _selectedQuantities[prod.id] ?? 0;
        if (qty > 0) productsSummary.add('${qty}x ${prod.name}');
      }

      final orderName = _nameController.text.isNotEmpty ? _nameController.text.trim() : 'Pedido #${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      if (widget.orderToEdit != null) {
        // Modo: Edição de Pedido Existente
        await ref.read(routeStopsProvider(widget.activeRoute.id).notifier).updateOrderInRoute(
          stopId: widget.orderToEdit!.id,
          orderName: orderName,
          notes: _notesController.text.trim(),
          latitude: _capturedLocation!.latitude,
          longitude: _capturedLocation!.longitude,
          captureMethod: _captureMethod,
          imagePath: finalImagePath,
          products: productsSummary,
        );
      } else {
        // Modo: Criação de Novo Pedido
        await ref.read(routeStopsProvider(widget.activeRoute.id).notifier).addOrderToRoute(
          route: widget.activeRoute,
          orderName: orderName,
          notes: _notesController.text.trim(),
          latitude: _capturedLocation!.latitude,
          longitude: _capturedLocation!.longitude,
          captureMethod: _captureMethod,
          imagePath: finalImagePath,
          products: productsSummary,
      );
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalog = ref.watch(productListProvider);
    final isEditing = widget.orderToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Detalhes do Pedido' : 'Adicionar Pedido à Rota')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Identificador (Opcional, ex: Porta B)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notas de entrega'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              Text('1. Coordenadas', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLocating ? null : _captureGPS,
                      icon: _isLocating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location),
                      label: const Text('Aqui'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openMapPicker,
                      icon: const Icon(Icons.map),
                      label: const Text('Mapa'),
                    ),
                  ),
                ],
              ),
              if (_capturedLocation != null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('📍 Local definido', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),

              const SizedBox(height: 24),

              Text('2. Foto do Local', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              
              if (_capturedImage != null)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: FileImage(_capturedImage!), fit: BoxFit.cover),
                  ),
                ),
                
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.surfaceContainerHighest),
                      onPressed: _takeNormalPhoto,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Física'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _capturedLocation == null ? null : _openStreetViewCamera,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _capturedLocation == null ? Colors.grey.shade800 : theme.colorScheme.primary.withValues(alpha: 0.2),
                        foregroundColor: theme.colorScheme.primary,
                      ),
                      icon: const Icon(Icons.streetview),
                      label: const Text('Street View'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('3. Produtos', style: theme.textTheme.titleMedium),
                  IconButton(icon: const Icon(Icons.add_circle, color: Colors.amber), onPressed: () => _showProductSelector(catalog)),
                ],
              ),
              ..._addedProducts.map((prod) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(prod.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() {
                        if (_selectedQuantities[prod.id]! > 1) {
                          _selectedQuantities[prod.id] = _selectedQuantities[prod.id]! - 1;
                        } else {
                          _addedProducts.remove(prod);
                          _selectedQuantities.remove(prod.id);
                        }
                      })),
                      Text('${_selectedQuantities[prod.id]}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() {
                        _selectedQuantities[prod.id] = _selectedQuantities[prod.id]! + 1;
                      })),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.black),
                  onPressed: _saveOrder,
                  child: Text(isEditing ? 'CONCLUÍDO / ATUALIZAR' : 'GUARDAR PEDIDO NA ROTA', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
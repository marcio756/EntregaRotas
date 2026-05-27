// Ficheiro: lib/features/routes/presentation/add_order_screen.dart
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
import '../../../core/utils/ui_utils.dart';
import '../../products/providers/product_provider.dart';
import '../providers/route_stop_provider.dart';
import 'interactive_map_picker_screen.dart'; 
import 'street_view_capture_screen.dart'; 

class AddOrderScreen extends ConsumerStatefulWidget {
  final DeliveryRoute activeRoute;
  final RouteStop? orderToEdit;

  const AddOrderScreen({super.key, required this.activeRoute, this.orderToEdit});

  @override
  ConsumerState<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends ConsumerState<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _zoneController = TextEditingController();
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
    _inheritLastLocationIfNew();
  }

  void _populateFieldsIfEditing() {
    if (widget.orderToEdit != null) {
      _nameController.text = widget.orderToEdit!.orderName;
      
      String rawNotes = widget.orderToEdit!.notes ?? '';
      if (rawNotes.startsWith('[ZONE:')) {
        final closeIdx = rawNotes.indexOf(']');
        if (closeIdx != -1) {
          _zoneController.text = rawNotes.substring(6, closeIdx);
          _notesController.text = rawNotes.substring(closeIdx + 1).trim();
        } else {
          _notesController.text = rawNotes;
        }
      } else {
        _notesController.text = rawNotes;
      }

      _capturedLocation = LatLng(widget.orderToEdit!.latitude, widget.orderToEdit!.longitude);
      _captureMethod = widget.orderToEdit!.locationCaptureMethod ?? 'INTERACTIVE_MAP';
      
      if (widget.orderToEdit!.localImagePath != null) {
        _capturedImage = File(widget.orderToEdit!.localImagePath!);
      }

      final catalog = ref.read(productListProvider);
      for (var summary in widget.orderToEdit!.productsToDeliver) {
        final cleanSummary = summary.split(' | orig: ')[0].trim();
        final parts = cleanSummary.split('x ');
        
        if (parts.length >= 2) {
          final qty = int.tryParse(parts[0]) ?? 0;
          final rawName = parts[1].trim(); 
          
          String pureName = rawName;
          String? extractedCategory;

          if (rawName.contains(' (')) {
            final firstParen = rawName.indexOf(' (');
            final lastParen = rawName.lastIndexOf(')');
            if (lastParen > firstParen) {
              pureName = rawName.substring(0, firstParen).trim();
              extractedCategory = rawName.substring(firstParen + 2, lastParen);
              
              if (extractedCategory == 'Geral') {
                extractedCategory = null;
              }
            }
          }

          try {
            final targetProduct = catalog.firstWhere((p) {
              bool nameMatches = p.name == pureName;
              bool catMatches = p.category == extractedCategory || (p.category == '' && extractedCategory == null);
              return nameMatches && catMatches;
            });
            
            _addedProducts.add(targetProduct);
            _selectedQuantities[targetProduct.id] = qty;
          } catch (_) {
            int safeId = pureName.hashCode ^ (extractedCategory?.hashCode ?? 0);
            if (safeId < 0) safeId = -safeId; 
            
            final runtimeProduct = Product()
              ..id = safeId
              ..name = pureName
              ..category = extractedCategory ?? 'Geral';
              
            _addedProducts.add(runtimeProduct);
            _selectedQuantities[runtimeProduct.id] = qty;
          }
        }
      }
    }
  }

  void _inheritLastLocationIfNew() {
    if (widget.orderToEdit == null) {
      final currentStops = ref.read(routeStopsProvider(widget.activeRoute.id.toString()));
      if (currentStops.isNotEmpty) {
        final lastStop = currentStops.last;
        setState(() {
          _capturedLocation = LatLng(lastStop.latitude, lastStop.longitude);
          _captureMethod = 'HERDADO_DO_ULTIMO';
          
          String rawNotes = lastStop.notes ?? '';
          if (rawNotes.startsWith('[ZONE:')) {
            final closeIdx = rawNotes.indexOf(']');
            if (closeIdx != -1) {
              _zoneController.text = rawNotes.substring(6, closeIdx);
            }
          }
        });
      }
    }
  }

  void _copyZoneFromLastOrder() {
    final currentStops = ref.read(routeStopsProvider(widget.activeRoute.id.toString()));
    if (currentStops.isNotEmpty) {
      // Procura do fim para o início o último pedido que tenha uma zona definida
      final lastStopWithZone = currentStops.reversed.firstWhere(
        (s) => s.notes != null && s.notes!.startsWith('[ZONE:'),
        orElse: () => RouteStop()..notes = null,
      );

      if (lastStopWithZone.notes != null) {
        final rawNotes = lastStopWithZone.notes!;
        final closeIdx = rawNotes.indexOf(']');
        if (closeIdx != -1) {
          setState(() {
            _zoneController.text = rawNotes.substring(6, closeIdx);
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zona copiada do último registo na rota.')));
          return;
        }
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhuma zona encontrada nos pedidos anteriores.')));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _zoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _captureGPS() async {
    setState(() => _isLocating = true);
    try {
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null && mounted) {
        setState(() {
          _capturedLocation = LatLng(lastPos.latitude, lastPos.longitude);
          _captureMethod = 'GPS_AUTO';
          _isLocating = false; 
        });
      }
      
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _capturedLocation = LatLng(position.latitude, position.longitude);
          _captureMethod = 'GPS_AUTO';
          _isLocating = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLocating = false);
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
        
        if (widget.orderToEdit?.localImagePath != null) {
          await _fileService.deleteImageLocally(widget.orderToEdit!.localImagePath!);
        }
      }

      final List<String> productsSummary = [];
      for (var prod in _addedProducts) {
        final qty = _selectedQuantities[prod.id] ?? 0;
        if (qty > 0) productsSummary.add('${qty}x ${prod.name} (${prod.category ?? 'Geral'})');
      }

      final orderName = _nameController.text.isNotEmpty ? _nameController.text.trim() : 'Pedido #${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      String finalNotes = _notesController.text.trim();
      String zone = _zoneController.text.trim();
      if (zone.isNotEmpty) {
        finalNotes = '[ZONE:$zone] $finalNotes';
      }

      if (widget.orderToEdit != null) {
        await ref.read(routeStopsProvider(widget.activeRoute.id.toString()).notifier).updateOrderInRoute(
          stopId: widget.orderToEdit!.id,
          orderName: orderName,
          notes: finalNotes,
          latitude: _capturedLocation!.latitude,
          longitude: _capturedLocation!.longitude,
          captureMethod: _captureMethod,
          imagePath: finalImagePath,
          products: productsSummary,
        );
      } else {
        await ref.read(routeStopsProvider(widget.activeRoute.id.toString()).notifier).addOrderToRoute(
          route: widget.activeRoute,
          orderName: orderName,
          notes: finalNotes,
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

  void _deleteOrder() {
    final backupOrder = widget.orderToEdit!;
    final routeIdStr = widget.activeRoute.id.toString();
    
    ref.read(routeStopsProvider(routeIdStr).notifier).deleteOrder(backupOrder.id);
    Navigator.pop(context);

    UiUtils.showUndoToast(context, 'Pedido "${backupOrder.orderName}" apagado.', () {
      ref.read(routeStopsProvider(routeIdStr).notifier).restoreOrder(backupOrder);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalog = ref.watch(productListProvider);
    final isEditing = widget.orderToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Detalhes' : 'Adicionar à Rota')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Identificador (ex: Sr. João)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _zoneController,
                decoration: InputDecoration(
                  labelText: 'Sub-rota / Zona (Opcional)',
                  hintText: 'ex: Paraíso, S. Cristóvão',
                  prefixIcon: Icon(Icons.map_outlined, color: theme.colorScheme.primary),
                  // BOTÃO DE CÓPIA ADICIONADO AQUI
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.content_copy),
                    color: theme.colorScheme.primary,
                    tooltip: 'Copiar zona do último pedido',
                    onPressed: _copyZoneFromLastOrder,
                  ),
                ),
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
                  subtitle: Text(prod.category ?? 'Geral', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)), 
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
              if (isEditing)
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error, foregroundColor: Colors.white),
                          onPressed: _deleteOrder,
                          child: const Icon(Icons.delete_outline),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.black),
                          onPressed: _saveOrder,
                          child: const Text('ATUALIZAR', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.black),
                    onPressed: _saveOrder,
                    child: const Text('GUARDAR PEDIDO NA ROTA', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
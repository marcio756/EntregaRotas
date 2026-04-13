import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../products/providers/product_provider.dart';
import '../providers/client_provider.dart';
import '../../../core/database/collections/client_point_collection.dart';
import '../../../core/database/collections/product_collection.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../routes/providers/route_stop_provider.dart';

class AddClientPointScreen extends ConsumerStatefulWidget {
  final DeliveryRoute? activeRoute;

  const AddClientPointScreen({super.key, this.activeRoute});

  @override
  ConsumerState<AddClientPointScreen> createState() => _AddClientPointScreenState();
}

class _AddClientPointScreenState extends ConsumerState<AddClientPointScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  
  Position? _capturedPosition;
  bool _isCapturingGPS = false;
  
  final Map<int, int> _selectedQuantities = {};
  final List<Product> _addedProducts = [];

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showProductSelector(List<Product> catalog) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: catalog.length,
        itemBuilder: (context, index) {
          final prod = catalog[index];
          return ListTile(
            leading: const Icon(Icons.bakery_dining),
            title: Text(prod.name),
            subtitle: Text(prod.category ?? 'Geral'),
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

  Future<void> _captureLocation() async {
    setState(() => _isCapturingGPS = true);
    try {
      Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 4),
      ).onError((error, stackTrace) => Geolocator.getLastKnownPosition().then((value) => value!));

      if (mounted) setState(() { _capturedPosition = position; _isCapturingGPS = false; });
    } catch (e) {
      setState(() => _isCapturingGPS = false);
    }
  }

  void _resetLocation() {
    setState(() {
      _capturedPosition = null;
      _isCapturingGPS = false;
    });
  }

  Future<void> _saveClientPoint() async {
    if (_formKey.currentState!.validate()) {
      if (_capturedPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Captura GPS obrigatória.')));
        return;
      }

      String finalName = _nameController.text.trim();
      if (finalName.isEmpty) {
        final currentClientsCount = ref.read(clientListProvider).length;
        finalName = 'Cliente ${currentClientsCount + 1}';
      }

      final List<String> defaultOrder = [];
      for (var prod in _addedProducts) {
        final qty = _selectedQuantities[prod.id] ?? 0;
        if (qty > 0) {
          defaultOrder.add('${qty}x ${prod.name} (${prod.category ?? 'Geral'})');
        }
      }
      
      final newClient = ClientPoint()
        ..clientName = finalName
        ..deliveryNotes = _notesController.text.trim()
        ..latitude = _capturedPosition!.latitude
        ..longitude = _capturedPosition!.longitude
        ..defaultProducts = defaultOrder;

      // Grava o cliente globalmente
      await ref.read(clientListProvider.notifier).addClient(newClient);

      // Se viemos do mapa de trabalho, liga o cliente imediatamente à rota!
      if (widget.activeRoute != null) {
        await ref.read(routeStopsProvider(widget.activeRoute!.id).notifier)
           .addClientToRoute(widget.activeRoute!, newClient, defaultOrder);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalog = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Cliente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Nome (Vazio para "Cliente X")',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _notesController,
                label: 'Notas de Entrega',
                icon: Icons.note_alt_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              _buildGPSCaptureCard(theme),
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('Produtos Escolhidos', style: theme.textTheme.titleLarge, overflow: TextOverflow.ellipsis)),
                  TextButton.icon(
                    onPressed: () => _showProductSelector(catalog),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),
              const Divider(),
              
              if (_addedProducts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('Nenhum produto selecionado.', style: TextStyle(color: Colors.grey))),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _addedProducts.length,
                  itemBuilder: (context, index) {
                    final product = _addedProducts[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(product.name),
                      subtitle: Text(product.category ?? 'Geral'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => setState(() {
                              if (_selectedQuantities[product.id]! > 1) {
                                _selectedQuantities[product.id] = _selectedQuantities[product.id]! - 1;
                              } else {
                                _addedProducts.removeAt(index);
                                _selectedQuantities.remove(product.id);
                              }
                            }),
                          ),
                          Text('${_selectedQuantities[product.id]}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF64FFDA)),
                            onPressed: () => setState(() {
                              _selectedQuantities[product.id] = _selectedQuantities[product.id]! + 1;
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.black),
                  onPressed: _saveClientPoint,
                  child: const Text('GUARDAR CLIENTE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildGPSCaptureCard(ThemeData theme) {
    return InkWell(
      onTap: _isCapturingGPS || _capturedPosition != null ? null : _captureLocation,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: _capturedPosition != null ? theme.colorScheme.secondary.withValues(alpha: 0.1) : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _capturedPosition != null ? theme.colorScheme.secondary : const Color(0xFF333333)),
        ),
        child: Center(
          child: _isCapturingGPS 
            ? const CircularProgressIndicator()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_capturedPosition != null ? Icons.check_circle : Icons.gps_fixed, color: _capturedPosition != null ? Colors.green : theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _capturedPosition != null ? 'Localização Capturada' : 'Tocar para Capturar GPS Rápido',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (_capturedPosition != null)
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.grey),
                      onPressed: _resetLocation,
                      tooltip: 'Limpar Localização',
                    )
                ],
              ),
        ),
      ),
    );
  }
}
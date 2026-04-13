import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../../core/database/collections/client_point_collection.dart';
import '../../clients/providers/client_provider.dart';
import '../../products/providers/product_provider.dart';
import '../providers/route_stop_provider.dart';

/// Screen to select a physical client and allocate products/quantities for a specific route.
class RouteClientSelectionScreen extends ConsumerStatefulWidget {
  final DeliveryRoute route;

  const RouteClientSelectionScreen({super.key, required this.route});

  @override
  ConsumerState<RouteClientSelectionScreen> createState() => _RouteClientSelectionScreenState();
}

class _RouteClientSelectionScreenState extends ConsumerState<RouteClientSelectionScreen> {
  
  /// Opens a BottomSheet to define exactly what this client will receive on this route day.
  void _showProductAllocationSheet(ClientPoint client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ProductAllocationSheet(route: widget.route, client: client),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Cliente'),
      ),
      body: clients.isEmpty
          ? const Center(child: Text('Nenhum cliente registado no mapa ainda.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.person_pin_circle_outlined),
                    title: Text(client.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(client.contact ?? 'Sem contacto'),
                    trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF64FFDA)),
                    onTap: () => _showProductAllocationSheet(client),
                  ),
                );
              },
            ),
    );
  }
}

/// Inner widget to handle the specific quantities allocation without cluttering the main screen.
class _ProductAllocationSheet extends ConsumerStatefulWidget {
  final DeliveryRoute route;
  final ClientPoint client;

  const _ProductAllocationSheet({required this.route, required this.client});

  @override
  ConsumerState<_ProductAllocationSheet> createState() => _ProductAllocationSheetState();
}

class _ProductAllocationSheetState extends ConsumerState<_ProductAllocationSheet> {
  // Map to hold temporary quantities while the user adjusts them in the sheet
  final Map<String, int> _selectedQuantities = {};

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider);
    final theme = Theme.of(context);

    // Initialize quantities with the product's default quantity for speed.
    if (_selectedQuantities.isEmpty && products.isNotEmpty) {
      for (var p in products) {
        _selectedQuantities[p.name] = p.defaultQuantity ?? 0;
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Entregar a: ${widget.client.clientName}', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Ajuste as quantidades para este dia específico.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(child: Text('O Catálogo de produtos está vazio.')),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(product.name, style: const TextStyle(fontSize: 16)),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setState(() {
                                  if ((_selectedQuantities[product.name] ?? 0) > 0) {
                                    _selectedQuantities[product.name] = (_selectedQuantities[product.name] ?? 0) - 1;
                                  }
                                });
                              },
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${_selectedQuantities[product.name] ?? 0}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF64FFDA)),
                              onPressed: () {
                                setState(() {
                                  _selectedQuantities[product.name] = (_selectedQuantities[product.name] ?? 0) + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                // Compile final list ignoring zero quantities
                final List<String> deliverySummary = [];
                _selectedQuantities.forEach((prodName, qty) {
                  if (qty > 0) {
                    deliverySummary.add('${qty}x $prodName');
                  }
                });

                if (deliverySummary.isEmpty) {
                  Navigator.pop(context); // Cancel if nothing selected
                  return;
                }

                // Call the provider to save the relational link in Isar
                ref.read(routeStopsProvider(widget.route.id).notifier)
                   .addClientToRoute(widget.route, widget.client, deliverySummary);
                
                Navigator.pop(context); // Close Sheet
                Navigator.pop(context); // Close Selection Screen
              },
              child: const Text('CONFIRMAR ENTREGA', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
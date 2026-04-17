import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../../core/database/collections/client_point_collection.dart';
import '../../../core/database/collections/product_collection.dart';
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
  Widget build(BuildContext context) {
    // Todos os clientes da base de dados global
    final allClients = ref.watch(clientListProvider);
    // Paragens específicas apenas desta rota
    final routeStops = ref.watch(routeStopsProvider(widget.route.id));
    
    // OTIMIZAÇÃO: Filtrar os clientes que JÁ ESTÃO na rota atual para evitar duplicações
    final existingClientIds = routeStops.map((stop) => stop.clientPoint.value?.id).toSet();
    final availableClients = allClients.where((c) => !existingClientIds.contains(c.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Cliente'),
      ),
      body: allClients.isEmpty
          ? const Center(child: Text('Nenhum cliente registado no mapa ainda.'))
          : availableClients.isEmpty 
              ? const Center(child: Text('Todos os clientes já foram adicionados a esta rota.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: availableClients.length,
                  itemBuilder: (context, index) {
                    final client = availableClients[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.person_pin_circle_outlined),
                        title: Text(client.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(client.deliveryNotes ?? 'Sem notas de entrega'),
                        trailing: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary),
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
  final Map<int, int> _selectedQuantities = {};
  final List<Product> _activeInSheet = [];

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider);
    final theme = Theme.of(context);

    // Injeção da "Encomenda Padrão" do Cliente
    if (_selectedQuantities.isEmpty && products.isNotEmpty) {
      for (var item in widget.client.defaultProducts) {
        final parts = item.split('x ');
        if (parts.length >= 2) {
          final qty = int.tryParse(parts[0]) ?? 0;
          final productNameWithCategory = parts[1].trim();
          final pureName = productNameWithCategory.split(' (')[0];
          
          try {
            final p = products.firstWhere((prod) => prod.name == pureName);
            _selectedQuantities[p.id] = qty;
            _activeInSheet.add(p);
          } catch (e) {
            // Ignora se o produto foi apagado do catálogo entretanto
          }
        }
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
          
          if (_activeInSheet.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(child: Text('Este cliente não tem encomenda padrão configurada.', textAlign: TextAlign.center)),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _activeInSheet.length,
                itemBuilder: (context, index) {
                  final product = _activeInSheet[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: const TextStyle(fontSize: 16)),
                              if (product.category != null)
                                Text(product.category!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setState(() {
                                  if ((_selectedQuantities[product.id] ?? 0) > 0) {
                                    _selectedQuantities[product.id] = (_selectedQuantities[product.id] ?? 0) - 1;
                                  }
                                });
                              },
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${_selectedQuantities[product.id] ?? 0}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                              onPressed: () {
                                setState(() {
                                  _selectedQuantities[product.id] = (_selectedQuantities[product.id] ?? 0) + 1;
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
                final List<String> deliverySummary = [];
                _selectedQuantities.forEach((id, qty) {
                  if (qty > 0) {
                    final p = products.firstWhere((prod) => prod.id == id);
                    deliverySummary.add('${qty}x ${p.name}');
                  }
                });

                if (deliverySummary.isEmpty) {
                  Navigator.pop(context);
                  return;
                }

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
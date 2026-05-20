// Ficheiro: lib/features/routes/presentation/route_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../../core/database/collections/route_stop_collection.dart';
import '../providers/route_stop_provider.dart';
import 'add_order_screen.dart'; 
import 'route_load_sheet_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Displays and manages the specific orders (stops) allocated to a Delivery Route.
class RouteDetailsScreen extends ConsumerWidget {
  final DeliveryRoute route;

  const RouteDetailsScreen({super.key, required this.route});

  void _confirmDelete(BuildContext context, WidgetRef ref, RouteStop stop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar Pedido?'),
        content: Text('Tem a certeza que deseja remover o pedido "${stop.orderName}" desta rota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              ref.read(routeStopsProvider(route.id.toString()).notifier).deleteOrder(stop.id);
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
    final stops = ref.watch(routeStopsProvider(route.id.toString()));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gerir: ${route.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Guia de Carga Geral',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RouteLoadSheetScreen(
                    activeRoutes: [route], 
                    sessionName: route.name, 
                    sessionIds: route.id.toString(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: stops.isEmpty
          ? Center(
              child: Text(
                'Ainda não existem pedidos nesta rota.',
                style: TextStyle(color: Colors.grey.shade600),
              ).animate().fadeIn().scale(),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              itemCount: stops.length,
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final List<RouteStop> reorderedStops = List.from(stops);
                final item = reorderedStops.removeAt(oldIndex);
                reorderedStops.insert(newIndex, item);
                
                ref.read(routeStopsProvider(route.id.toString()).notifier).updateStopsOrder(reorderedStops);
              },
              itemBuilder: (context, index) {
                final stop = stops[index];

                return Dismissible(
                  key: ValueKey(stop.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_sweep, color: Colors.white, size: 32),
                  ),
                  confirmDismiss: (direction) async {
                    _confirmDelete(context, ref, stop);
                    return false; 
                  },
                  child: Card(
                    key: ValueKey('card_${stop.id}'),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        child: Text('${index + 1}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(stop.orderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        stop.productsToDeliver.join(', '), 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddOrderScreen(
                              activeRoute: route,
                              orderToEdit: stop,
                            ),
                          ),
                        );
                      },
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Icon(Icons.drag_indicator, color: Colors.grey, size: 32),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddOrderScreen(activeRoute: route),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('NOVO PEDIDO', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
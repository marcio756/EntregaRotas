import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/collections/route_collection.dart';
import '../providers/route_stop_provider.dart';
import 'route_client_selection_screen.dart'; // Importação adicionada

/// Displays the physical stops allocated to a specific Delivery Route.
class RouteDetailsScreen extends ConsumerWidget {
  final DeliveryRoute route;

  const RouteDetailsScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta apenas as paragens desta rota específica
    final stops = ref.watch(routeStopsProvider(route.id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(route.name),
      ),
      body: stops.isEmpty
          ? Center(
              child: Text(
                'Ainda não adicionaste clientes a esta rota.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                final client = stop.clientPoint.value; // Relational data

                if (client == null) return const SizedBox.shrink();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      child: Text('${index + 1}', style: TextStyle(color: theme.colorScheme.primary)),
                    ),
                    title: Text(client.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(stop.productsToDeliver.join(', ')),
                    trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegação com UI Transition para o ecrã de seleção de clientes
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RouteClientSelectionScreen(route: route),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('ADICIONAR CLIENTE'),
      ),
    );
  }
}
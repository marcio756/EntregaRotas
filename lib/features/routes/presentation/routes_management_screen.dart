// Ficheiro: lib/features/routes/presentation/routes_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/route_provider.dart';
import 'route_details_screen.dart'; 
import '../../../core/database/collections/route_collection.dart';

class RoutesManagementScreen extends ConsumerWidget {
  const RoutesManagementScreen({super.key});

  void _showAddRouteDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Rota'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Ex: Segunda-feira'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(routeListProvider.notifier).addRoute(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showEditRouteDialog(BuildContext context, WidgetRef ref, DeliveryRoute route) {
    final controller = TextEditingController(text: route.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Nome da Rota'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome da Rota'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final newName = controller.text.trim();
                await ref.read(routeListProvider.notifier).updateRoute(route.id, newName);
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  void _showDeleteRouteDialog(BuildContext context, WidgetRef ref, DeliveryRoute route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Apagar esta Rota?'),
          ],
        ),
        content: Text(
          'Tens a certeza absoluta que desejas eliminar permanentemente a rota "${route.name}" e todos os seus pedidos de entrega?\n\nEsta ação não pode ser recuperada!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context); // Fecha a janela de aviso
              await ref.read(routeListProvider.notifier).deleteRoute(route.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Rota "${route.name}" apagada com sucesso.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('APAGAR PERMANENTEMENTE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Rotas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddRouteDialog(context, ref),
          )
        ],
      ),
      body: routes.isEmpty
          ? const Center(child: Text('Nenhuma rota criada.'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(route.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditRouteDialog(context, ref, route);
                        } else if (value == 'delete') {
                          _showDeleteRouteDialog(context, ref, route);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_note, size: 22),
                              SizedBox(width: 10),
                              Text('Editar Nome'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_forever, color: Colors.redAccent, size: 22),
                              SizedBox(width: 10),
                              Text('Apagar Rota', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RouteDetailsScreen(route: route),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
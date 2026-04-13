import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/route_provider.dart';
import 'route_details_screen.dart'; // Nova importação

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
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                return ListTile(
                  title: Text(route.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navegação Drill-down para os detalhes da rota
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RouteDetailsScreen(route: route),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
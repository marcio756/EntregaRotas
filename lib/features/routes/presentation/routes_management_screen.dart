// Ficheiro: lib/features/routes/presentation/routes_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/route_provider.dart';
import '../providers/route_group_provider.dart';
import 'route_details_screen.dart'; 
import '../../../core/database/collections/route_collection.dart';
import '../../../core/database/collections/route_group_collection.dart';

class RoutesManagementScreen extends ConsumerWidget {
  const RoutesManagementScreen({super.key});

  void _showAddRouteDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Rota Simples'),
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

  void _showAddGroupDialog(BuildContext context, WidgetRef ref, List<DeliveryRoute> allRoutes) {
    final controller = TextEditingController();
    final selectedRoutes = <DeliveryRoute>[];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Novo Grupo de Rotas'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'Ex: Domingo (Agregado)'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Seleciona as rotas a incluir:'),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: allRoutes.length,
                        itemBuilder: (context, i) {
                          final r = allRoutes[i];
                          final isSelected = selectedRoutes.contains(r);
                          return CheckboxListTile(
                            title: Text(r.name),
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedRoutes.add(r);
                                } else {
                                  selectedRoutes.remove(r);
                                }
                              });
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty && selectedRoutes.isNotEmpty) {
                      ref.read(routeGroupListProvider.notifier).addGroup(controller.text, selectedRoutes);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar Grupo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditGroupDialog(BuildContext context, WidgetRef ref, RouteGroup group, List<DeliveryRoute> allRoutes) {
    final controller = TextEditingController(text: group.name);
    // Cria uma cópia com as rotas que já estavam ativas no momento
    final selectedRoutes = <DeliveryRoute>[...group.routes];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Grupo de Rotas'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: 'Nome do Grupo'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Modifica as rotas anexas:'),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: allRoutes.length,
                        itemBuilder: (context, i) {
                          final r = allRoutes[i];
                          // Match comparativo pelo ID real e não apenas referência na memória
                          final isSelected = selectedRoutes.any((sr) => sr.id == r.id);
                          
                          return CheckboxListTile(
                            title: Text(r.name),
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedRoutes.add(r);
                                } else {
                                  selectedRoutes.removeWhere((sr) => sr.id == r.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty && selectedRoutes.isNotEmpty) {
                      ref.read(routeGroupListProvider.notifier).updateGroup(group.id, controller.text.trim(), selectedRoutes);
                      Navigator.pop(context);
                    } else if (selectedRoutes.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, inclua pelo menos 1 Rota no Grupo.', style: TextStyle(color: Colors.white))));
                    }
                  },
                  child: const Text('GUARDAR'),
                ),
              ],
            );
          },
        );
      },
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ref.read(routeListProvider.notifier).updateRoute(route.id, controller.text.trim());
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
        title: const Text('Apagar esta Rota?', style: TextStyle(color: Colors.red)),
        content: Text('Desejas eliminar "${route.name}" permanentemente?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(routeListProvider.notifier).deleteRoute(route.id);
            },
            child: const Text('APAGAR'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteGroupDialog(BuildContext context, WidgetRef ref, RouteGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar Grupo?', style: TextStyle(color: Colors.red)),
        content: Text('Desejas remover o grupo "${group.name}"? As rotas e os pedidos não serão apagados, apenas este atalho.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(routeGroupListProvider.notifier).deleteGroup(group.id);
            },
            child: const Text('APAGAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routeListProvider);
    final groups = ref.watch(routeGroupListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Rotas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_add),
            tooltip: 'Criar Grupo (Ex: Domingo)',
            onPressed: () => _showAddGroupDialog(context, ref, routes),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Criar Rota Simples',
            onPressed: () => _showAddRouteDialog(context, ref),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (groups.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Grupos de Rotas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
            ),
            ...groups.map((group) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.amber, width: 0.5)),
              child: ListTile(
                leading: const Icon(Icons.layers, color: Colors.amber),
                title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${group.routes.length} Rotas conectadas'),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditGroupDialog(context, ref, group, routes);
                    } else if (value == 'delete') {
                      _showDeleteGroupDialog(context, ref, group);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_note), SizedBox(width: 10), Text('Editar Grupo')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_forever, color: Colors.redAccent), SizedBox(width: 10), Text('Apagar Grupo', style: TextStyle(color: Colors.redAccent))])),
                  ],
                ),
              ),
            )),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: Color(0xFF333333)),
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Rotas Individuais', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          if (routes.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('Nenhuma rota criada.', textAlign: TextAlign.center))
          else
            ...routes.map((route) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
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
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_note), SizedBox(width: 10), Text('Editar Nome')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_forever, color: Colors.redAccent), SizedBox(width: 10), Text('Apagar Rota', style: TextStyle(color: Colors.redAccent))])),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RouteDetailsScreen(route: route)));
                },
              ),
            )),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/client_provider.dart';
import 'add_client_point_screen.dart';
import '../../../core/database/collections/client_point_collection.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Allows drivers or managers to visualize and manage all physical clients globally.
class ClientsListScreen extends ConsumerWidget {
  const ClientsListScreen({super.key});

  void _confirmDelete(BuildContext context, WidgetRef ref, ClientPoint client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar Cliente?'),
        content: Text('Tem a certeza que deseja apagar "${client.clientName}"? Esta ação removerá o cliente da base de dados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              ref.read(clientListProvider.notifier).deleteClient(client.id);
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
    final clients = ref.watch(clientListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestão de Clientes')),
      body: clients.isEmpty
          ? Center(
              child: const Text('Nenhum cliente registado.')
                  .animate().fadeIn().scale(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.person_pin_circle_rounded, color: theme.colorScheme.primary),
                    ),
                    title: Text(client.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      client.deliveryNotes?.isNotEmpty == true 
                        ? client.deliveryNotes! 
                        : 'Sem notas de entrega',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                      onPressed: () => _confirmDelete(context, ref, client),
                    ),
                    onTap: () {
                      // Drill Transition for future edit logic
                    },
                  ),
                ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'clients_fab_unique_tag', // Correção adicionada aqui
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddClientPointScreen()),
          );
        },
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('NOVO CLIENTE'),
      ),
    );
  }
}
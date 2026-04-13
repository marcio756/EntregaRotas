import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/providers/route_provider.dart';
import '../../delivery/presentation/delivery_execution_screen.dart';

/// The primary landing page of the application.
/// Focuses on the "Start Working" action to initiate a specific delivery route.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bakery_dining, size: 80, color: theme.colorScheme.primary)
                .animate().fadeIn().scale(),
            const SizedBox(height: 24),
            Text(
              'Distribuição de Pão',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Text('Pronto para a rota de hoje?', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 64),
            
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => _showRouteSelection(context, ref),
                icon: const Icon(Icons.play_arrow_rounded, size: 32),
                label: const Text('COMEÇAR A TRABALHAR', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ).animate().shimmer(delay: 1.seconds, duration: 2.seconds),
          ],
        ),
      ),
    );
  }

  /// Opens a Bottom Sheet to select which Route is being executed today.
  void _showRouteSelection(BuildContext context, WidgetRef ref) {
    final routes = ref.read(routeListProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        if (routes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('Nenhuma rota criada. Crie uma rota no menu "Rotas" primeiro.'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Qual rota vais iniciar?', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...routes.map((route) => Card(
                child: ListTile(
                  title: Text(route.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.pop(context); // Fecha a sheet
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DeliveryExecutionScreen(activeRoute: route),
                      ),
                    );
                  },
                ),
              )),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
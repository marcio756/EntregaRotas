import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../routes/providers/route_stop_provider.dart';
import '../../products/providers/product_provider.dart';

/// Provides a dynamic dashboard at the end of the route.
/// Displays total deliveries made, products delivered, and calculated values to receive.
class DailySummaryScreen extends ConsumerWidget {
  final DeliveryRoute activeRoute;

  const DailySummaryScreen({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // 1. Obter estado atual das paragens e o catálogo de produtos
    final stops = ref.watch(routeStopsProvider(activeRoute.id));
    final products = ref.watch(productListProvider);

    // 2. Filtrar estritamente as entregas efetuadas
    final deliveredStops = stops.where((s) => s.isDelivered).toList();

    // 3. Inicializar motores de cálculo dinâmico
    int totalDeliveries = deliveredStops.length;
    double totalValueToReceive = 0.0;
    Map<String, int> deliveredStock = {};

    // 4. Processar agregações de stock e valor
    for (var stop in deliveredStops) {
      for (var item in stop.productsToDeliver) {
        final parts = item.split('x ');
        if (parts.length >= 2) {
          final qty = int.tryParse(parts[0]) ?? 0;
          
          // Isolar apenas o nome base do produto (ignora sufixos de categorias ex: "(Geral)")
          final rawName = parts[1].trim();
          final pureName = rawName.split(' (')[0].trim();

          // Incrementar stock global entregue
          deliveredStock[pureName] = (deliveredStock[pureName] ?? 0) + qty;

          // Cruzar com o catálogo para calcular valor
          try {
            final product = products.firstWhere((p) => p.name == pureName);
            totalValueToReceive += (product.unitPrice ?? 0.0) * qty;
          } catch (e) {
            // Ignorar graciosamente se o produto foi apagado do catálogo entretanto
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo Diário', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(Icons.verified_rounded, size: 64, color: theme.colorScheme.primary)
                      .animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  Text('Rota Concluída!', style: theme.textTheme.titleLarge?.copyWith(fontSize: 28)),
                  const Text('Bom trabalho. Aqui está o resumo de hoje.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            Text('Métricas Principais', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMetricCard(theme, 'Entregas', '$totalDeliveries', Icons.local_shipping_outlined)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard(theme, 'A Receber', '€ ${totalValueToReceive.toStringAsFixed(2)}', Icons.euro_outlined)),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 32),
            Text('Controlo de Stock (Entregue)', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildStockList(theme, deliveredStock).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  /// Reusable widget for top-level numeric metrics.
  Widget _buildMetricCard(ThemeData theme, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontSize: 24, color: theme.colorScheme.primary)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  /// Builds the dynamically calculated list of all products delivered.
  Widget _buildStockList(ThemeData theme, Map<String, int> stockData) {
    if (stockData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: const Center(child: Text('Nenhum produto entregue hoje.', style: TextStyle(color: Colors.grey))),
      );
    }

    final entries = stockData.entries.toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entries.length,
        separatorBuilder: (context, index) => const Divider(color: Color(0xFF333333), height: 1),
        itemBuilder: (context, index) {
          final item = entries[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(item.key, style: theme.textTheme.bodyLarge),
            trailing: Text(
              '${item.value} un.', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          );
        },
      ),
    );
  }
}
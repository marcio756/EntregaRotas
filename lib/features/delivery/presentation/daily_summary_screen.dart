// Ficheiro: lib/features/delivery/presentation/daily_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../../core/services/history_service.dart';
import '../../routes/providers/route_stop_provider.dart';
import '../../products/providers/product_provider.dart';

/// Provides a dynamic dashboard at the end of the route.
/// Displays total deliveries made, products delivered, and calculated values to receive.
class DailySummaryScreen extends ConsumerWidget {
  final DeliveryRoute activeRoute;
  final HistoryService _historyService = HistoryService();

  DailySummaryScreen({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // 1. Obter estado atual das paragens e o catálogo de produtos
    final stops = ref.watch(routeStopsProvider(activeRoute.id));
    final products = ref.watch(productListProvider);

    // 2. Inicializar motores de cálculo dinâmico e contadores específicos por desvio
    int totalDeliveries = stops.where((s) => s.isDelivered).length;
    double totalValueToReceive = 0.0;
    
    final Map<String, int> deliveredStock = {};
    final Map<String, int> notDeliveredStock = {};
    final Map<String, int> extraStock = {};

    // 3. Processar agregações avançadas de stock com base nos metadados inlined
    for (var stop in stops) {
      for (var item in stop.productsToDeliver) {
        final parts = item.split('x ');
        if (parts.length >= 2) {
          final currentQty = int.tryParse(parts[0]) ?? 0;
          final remainder = parts[1].trim();
          
          int originalQty = currentQty;
          String pureProductInfo = remainder;

          if (remainder.contains(' | orig: ')) {
            final subParts = remainder.split(' | orig: ');
            pureProductInfo = subParts[0].trim();
            originalQty = int.tryParse(subParts[1]) ?? currentQty;
          }

          final pureName = pureProductInfo.split(' (')[0].trim();

          if (stop.isDelivered) {
            // Se a casa foi marcada como entregue
            if (currentQty > 0) {
              deliveredStock[pureName] = (deliveredStock[pureName] ?? 0) + currentQty;
            }
            
            if (currentQty > originalQty) {
              extraStock[pureName] = (extraStock[pureName] ?? 0) + (currentQty - originalQty);
            } else if (currentQty < originalQty) {
              notDeliveredStock[pureName] = (notDeliveredStock[pureName] ?? 0) + (originalQty - currentQty);
            }

            // Cruzar com o catálogo para calcular valor financeiro líquido
            try {
              final product = products.firstWhere((p) => p.name == pureName);
              totalValueToReceive += (product.unitPrice ?? 0.0) * currentQty;
            } catch (_) {}
          } else {
            // Se o cliente não foi entregue, toda a quantidade original vai para Falta
            notDeliveredStock[pureName] = (notDeliveredStock[pureName] ?? 0) + originalQty;
          }
        }
      }
    }

    Future<void> concludeAndSaveDay(BuildContext ctx) async {
      final now = DateTime.now();
      final formattedDate = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
      
      await _historyService.saveDaySummary(
        dateStr: formattedDate,
        routeName: activeRoute.name,
        delivered: deliveredStock,
        notDelivered: notDeliveredStock,
        extra: extraStock,
      );

      // Repor as flags de entrega da rota local para o Domingo seguinte automaticamente
      await ref.read(routeStopsProvider(activeRoute.id).notifier).resetRouteCompletion();

      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Resumo de hoje gravado no Histórico com sucesso! Rota limpa para a próxima semana.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(ctx).popUntil((route) => route.isFirst);
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
            const SizedBox(height: 32),
            
            Text('Métricas Principais', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMetricCard(theme, 'Entregas', '$totalDeliveries', Icons.local_shipping_outlined)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard(theme, 'A Receber', '€ ${totalValueToReceive.toStringAsFixed(2)}', Icons.euro_outlined)),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 24),
            Text('Controlo de Stock (Entregue)', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildStockList(theme, deliveredStock, Colors.green.shade400, 'un. entregues'),

            const SizedBox(height: 24),
            Text('Faltas / Não Entregues', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error)),
            const SizedBox(height: 12),
            _buildStockList(theme, notDeliveredStock, theme.colorScheme.error, 'un. em falta'),

            const SizedBox(height: 24),
            Text('Entregues a Mais', style: theme.textTheme.titleLarge?.copyWith(color: Colors.lightBlue)),
            const SizedBox(height: 12),
            _buildStockList(theme, extraStock, Colors.lightBlue, 'un. a mais'),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => concludeAndSaveDay(context),
                icon: const Icon(Icons.archive_outlined, size: 26),
                label: const Text('GRAVAR E FECHAR DIA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ),
            const SizedBox(height: 24),
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
  Widget _buildStockList(ThemeData theme, Map<String, int> stockData, Color accentColor, String badgeText) {
    if (stockData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: const Center(child: Text('Sem registos para esta categoria.', style: TextStyle(color: Colors.grey, fontSize: 13))),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            title: Text(item.key, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            trailing: Text(
              '${item.value} $badgeText', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: accentColor),
            ),
          );
        },
      ),
    );
  }
}
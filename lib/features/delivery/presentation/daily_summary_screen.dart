// Ficheiro: lib/features/delivery/presentation/daily_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../../core/services/history_service.dart';
import '../../routes/providers/route_stop_provider.dart';
import '../../products/providers/product_provider.dart';

/// Provides a dynamic dashboard at the end of the route session.
class DailySummaryScreen extends ConsumerWidget {
  final List<DeliveryRoute> activeRoutes;
  final String sessionName;
  final String sessionIds;
  final HistoryService _historyService = HistoryService();

  DailySummaryScreen({
    super.key, 
    required this.activeRoutes,
    required this.sessionName,
    required this.sessionIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Ignora na totalidade os pedidos desativados para que não manchem o relatório financeiro
    final stops = ref.watch(routeStopsProvider(sessionIds)).where((s) => s.isActive).toList();
    final products = ref.watch(productListProvider);

    int totalDeliveries = stops.where((s) => s.isDelivered).length;
    double totalValueToReceive = 0.0;
    
    final Map<String, int> deliveredStock = {};
    final Map<String, int> notDeliveredStock = {};
    final Map<String, int> extraStock = {};

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

          // A chave para exibir na interface será o Nome Completo + (Categoria)
          final displayName = pureProductInfo; 
          
          // A chave de pesquisa financeira retira a categoria para poder cruzar com o catálogo Isar
          final searchName = pureProductInfo.split(' (')[0].trim(); 

          if (stop.isDelivered) {
            if (currentQty > 0) deliveredStock[displayName] = (deliveredStock[displayName] ?? 0) + currentQty;
            
            if (currentQty > originalQty) {
              extraStock[displayName] = (extraStock[displayName] ?? 0) + (currentQty - originalQty);
            } else if (currentQty < originalQty) {
              notDeliveredStock[displayName] = (notDeliveredStock[displayName] ?? 0) + (originalQty - currentQty);
            }

            try {
              final product = products.firstWhere((p) => p.name == searchName);
              totalValueToReceive += (product.unitPrice ?? 0.0) * currentQty;
            } catch (_) {}
          } else {
            notDeliveredStock[displayName] = (notDeliveredStock[displayName] ?? 0) + originalQty;
          }
        }
      }
    }

    Future<void> concludeAndSaveDay(BuildContext ctx) async {
      final now = DateTime.now();
      final formattedDate = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
      
      await _historyService.saveDaySummary(
        dateStr: formattedDate,
        routeName: sessionName, 
        delivered: deliveredStock,
        notDelivered: notDeliveredStock,
        extra: extraStock,
      );

      await ref.read(routeStopsProvider(sessionIds).notifier).resetRouteCompletion();
      
      // INJEÇÃO ARQUITETURAL: Forçar a atualização reativa do histórico global 
      // para que a View atualize mesmo estando escondida sob o IndexedStack.
      ref.invalidate(historyLogsProvider);

      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Resumo de hoje gravado no Histórico com sucesso! Trabalho limpo para o próximo ciclo.'),
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
                  Icon(Icons.verified_rounded, size: 64, color: theme.colorScheme.primary).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  Text('Trabalho Concluído!', style: theme.textTheme.titleLarge?.copyWith(fontSize: 28)),
                  const Text('Bom trabalho. Aqui está o resumo final.', style: TextStyle(color: Colors.grey)),
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
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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

  Widget _buildMetricCard(ThemeData theme, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF333333))),
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

  Widget _buildStockList(ThemeData theme, Map<String, int> stockData, Color accentColor, String badgeText) {
    if (stockData.isEmpty) {
      return Container(
        width: double.infinity, 
        padding: const EdgeInsets.all(16), 
        decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF333333))), 
        child: const Center(child: Text('Sem registos para esta categoria.', style: TextStyle(color: Colors.grey, fontSize: 13)))
      );
    }
    
    final entries = stockData.entries.toList();
    return Container(
      decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF333333))),
      child: ListView.separated(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: entries.length,
        separatorBuilder: (context, index) => const Divider(color: Color(0xFF333333), height: 1),
        itemBuilder: (context, index) {
          final item = entries[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            title: Text(item.key, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            trailing: Text('${item.value} $badgeText', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: accentColor)),
          );
        },
      ),
    );
  }
}
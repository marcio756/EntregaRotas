import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Provides a simple dashboard at the end of the route.
/// Displays total deliveries made, products delivered (for van stock control), 
/// and values to receive.
class DailySummaryScreen extends StatelessWidget {
  const DailySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                Expanded(child: _buildMetricCard(theme, 'Entregas', '124', Icons.local_shipping_outlined)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard(theme, 'A Receber', '€ 85.50', Icons.euro_outlined)),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 32),
            Text('Controlo de Stock (Carro)', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildStockList(theme).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
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

  /// Builds the summarized list of all products delivered for physical stock check.
  Widget _buildStockList(ThemeData theme) {
    final stockData = [
      {"name": "Carcaças", "qty": 450},
      {"name": "Pão de Forma", "qty": 32},
      {"name": "Pão de Centeio", "qty": 15},
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stockData.length,
        separatorBuilder: (context, index) => const Divider(color: Color(0xFF333333), height: 1),
        itemBuilder: (context, index) {
          final item = stockData[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(item['name'] as String, style: theme.textTheme.bodyLarge),
            trailing: Text(
              '${item['qty']} un.', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          );
        },
      ),
    );
  }
}
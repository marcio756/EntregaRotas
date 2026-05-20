// Ficheiro: lib/features/routes/presentation/route_load_sheet_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/database/collections/route_collection.dart';
import '../providers/route_stop_provider.dart';

/// Screen dedicated to presenting the aggregated sum of all products
/// required for a specific delivery session (single route or grouped routes). Acts as the pre-departure Load Sheet.
class RouteLoadSheetScreen extends ConsumerWidget {
  final List<DeliveryRoute> activeRoutes;
  final String sessionName;
  final String sessionIds;

  const RouteLoadSheetScreen({
    super.key, 
    required this.activeRoutes,
    required this.sessionName,
    required this.sessionIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadTotals = ref.watch(routeLoadSummaryProvider(sessionIds));
    final theme = Theme.of(context);

    int totalItems = loadTotals.values.fold(0, (sum, item) => sum + item);
    final sortedEntries = loadTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text('Carga: $sessionName'),
        centerTitle: true,
      ),
      body: sortedEntries.isEmpty
          ? Center(
              child: Text(
                'A sessão não tem produtos agendados.',
                style: TextStyle(color: Colors.grey.shade600),
              ).animate().fadeIn().scale(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: theme.colorScheme.primary)
                            .animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 16),
                        Text('Resumo de Carga', style: theme.textTheme.titleLarge?.copyWith(fontSize: 28)),
                        Text('Total a colocar na carrinha: $totalItems unidades', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  Text('Inventário Necessário', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedEntries.length,
                      separatorBuilder: (context, index) => const Divider(color: Color(0xFF333333), height: 1),
                      itemBuilder: (context, index) {
                        final item = sortedEntries[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            child: Icon(Icons.bakery_dining, color: theme.colorScheme.primary, size: 20),
                          ),
                          title: Text(item.key, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
                          trailing: Text(
                            '${item.value} un.', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.colorScheme.primary),
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
    );
  }
}
// Ficheiro: lib/features/delivery/presentation/widgets/route_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/database/collections/route_stop_collection.dart';
import '../../../../core/utils/geo_utils.dart';
import 'delivery_card.dart';

/// Abstraction of the Map-First Bottom Sheet list structure.
/// Maintains the parent screen highly readable and manages Continuity Transitions naturally via DraggableScrollableSheet.
class RouteBottomSheet extends StatelessWidget {
  final List<RouteStop> pendingStops;
  final Position? currentLocation;
  final Function(int, String) onDeliveryComplete;
  final Function(RouteStop) onStopTap;
  final Function(int stopId, int productIndex, bool isIncrement) onProductQuantityAdjust;

  const RouteBottomSheet({
    super.key,
    required this.pendingStops,
    this.currentLocation,
    required this.onDeliveryComplete,
    required this.onStopTap,
    required this.onProductQuantityAdjust,
  });

  /// Dynamically computes the consolidated breakdown of all missing items from the remaining route load.
  Map<String, int> _calculateRemainingTotals() {
    final Map<String, int> totals = {};
    for (var stop in pendingStops) {
      for (var productStr in stop.productsToDeliver) {
        final displayStr = productStr.split(' | orig: ')[0];
        final parts = displayStr.split('x ');
        if (parts.length == 2) {
          final qty = int.tryParse(parts[0]) ?? 0;
          final name = parts[1].trim();
          totals[name] = (totals[name] ?? 0) + qty;
        }
      }
    }
    return totals;
  }

  /// Calculates the absolute mathematical sum of all physical product units 
  /// that are still pending to be delivered across all remaining stops.
  int _calculateTotalItemsCount() {
    int totalUnitCount = 0;
    for (var stop in pendingStops) {
      for (var productStr in stop.productsToDeliver) {
        final displayStr = productStr.split(' | orig: ')[0];
        final parts = displayStr.split('x ');
        if (parts.length == 2) {
          final qty = int.tryParse(parts[0]) ?? 0;
          totalUnitCount += qty;
        }
      }
    }
    return totalUnitCount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remainingProducts = _calculateRemainingTotals();
    final totalItemsPending = _calculateTotalItemsCount();
    
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.15,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, -4))],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.format_list_bulleted, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            'Próximas Entregas (${pendingStops.length})', 
                            style: theme.textTheme.titleLarge
                          ),
                        ],
                      ),
                      // Premium counter badge to display the aggregate sum of all bread units left
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '$totalItemsPending un.',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Dynamic widget block representing the aggregated items summary to clear the route workload.
              if (remainingProducts.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2C2C2C)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.analytics_outlined, size: 18, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Carga Total em Falta para Acabar:', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: remainingProducts.entries.map((entry) {
                            return Chip(
                              backgroundColor: theme.scaffoldBackgroundColor,
                              side: const BorderSide(color: Color(0xFF444444)),
                              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                              avatar: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                                child: Text('${entry.value}', style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              label: Text(entry.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final stop = pendingStops[index];
                    bool isNear = false;
                    if (currentLocation != null) {
                      final distance = GeoUtils.calculateDistance(
                        currentLocation!.latitude, currentLocation!.longitude,
                        stop.latitude, stop.longitude,
                      );
                      isNear = distance <= 30.0;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: GestureDetector(
                        onTap: () => onStopTap(stop),
                        child: DeliveryCard(
                          clientName: stop.orderName,
                          address: stop.notes ?? 'Sem notas',
                          products: stop.productsToDeliver,
                          isNear: isNear,
                          imagePath: stop.localImagePath,
                          onDelivered: () => onDeliveryComplete(stop.id, stop.orderName),
                          onQuantityAdjust: (prodIdx, isInc) => onProductQuantityAdjust(stop.id, prodIdx, isInc),
                        ),
                      ),
                    );
                  },
                  // ARCHITECTURE CORRECTION: Removed artificial maximum list constraint of 5 items.
                  // For a real-world work delivery mapping tool, hiding upcoming elements diminishes planning visibility.
                  childCount: pendingStops.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
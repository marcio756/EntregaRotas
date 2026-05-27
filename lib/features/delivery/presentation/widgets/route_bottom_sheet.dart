// Ficheiro: lib/features/delivery/presentation/widgets/route_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/database/collections/route_stop_collection.dart';
import '../../../../core/utils/geo_utils.dart';
import 'delivery_card.dart';

class RouteBottomSheet extends StatefulWidget {
  final List<RouteStop> allStops; 
  final Position? currentLocation;
  final Function(int, bool) onDeliveryToggle; 
  final Function(RouteStop) onStopTap;
  final Function(int stopId, int productIndex, bool isIncrement) onProductQuantityAdjust;

  const RouteBottomSheet({
    super.key,
    required this.allStops,
    this.currentLocation,
    required this.onDeliveryToggle,
    required this.onStopTap,
    required this.onProductQuantityAdjust,
  });

  @override
  State<RouteBottomSheet> createState() => _RouteBottomSheetState();
}

class _RouteBottomSheetState extends State<RouteBottomSheet> {
  String? _selectedZone;
  int _deliveryLimit = 5; 
  bool _showDelivered = false;

  String? _extractZone(String? notes) {
    if (notes != null && notes.startsWith('[ZONE:')) {
      final closeIdx = notes.indexOf(']');
      if (closeIdx != -1) return notes.substring(6, closeIdx);
    }
    return null;
  }

  String _cleanNotes(String? notes) {
    if (notes != null && notes.startsWith('[ZONE:')) {
      final closeIdx = notes.indexOf(']');
      if (closeIdx != -1) return notes.substring(closeIdx + 1).trim();
    }
    return notes ?? 'Sem notas';
  }

  Map<String, int> _calculateRemainingTotals(List<RouteStop> pendingStops) {
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

  int _calculateTotalItemsCount(List<RouteStop> pendingStops) {
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
    
    final availableZones = widget.allStops
        .map((s) => _extractZone(s.notes))
        .where((z) => z != null && z.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    final filteredByZone = widget.allStops.where((s) {
      if (_selectedZone == null) return true;
      return _extractZone(s.notes) == _selectedZone;
    }).toList();

    final deliveredStops = filteredByZone.where((s) => s.isDelivered).toList();
    final pendingStops = filteredByZone.where((s) => !s.isDelivered).toList();

    // 1. Limitar os pedidos visuais em primeiro lugar
    final limitedPending = _deliveryLimit == 0 
        ? pendingStops 
        : pendingStops.take(_deliveryLimit).toList();

    // 2. Os cálculos baseiam-se agora EXCLUSIVAMENTE nos pedidos que estão a ser mostrados
    final remainingProducts = _calculateRemainingTotals(limitedPending);
    final totalItemsPending = _calculateTotalItemsCount(limitedPending);

    // 3. Juntar o histórico (caso esteja ativo) com os pendentes limitados
    final displayedStops = [
      if (_showDelivered) ...deliveredStops,
      ...limitedPending,
    ];
    
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.85,
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
                    decoration: BoxDecoration(color: Colors.grey.shade600, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              
              if (availableZones.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        ChoiceChip(
                          label: const Text('Todas as Rotas', style: TextStyle(fontWeight: FontWeight.bold)),
                          selected: _selectedZone == null,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedZone = null);
                          },
                          selectedColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(color: _selectedZone == null ? Colors.black : Colors.white),
                        ),
                        const SizedBox(width: 8),
                        ...availableZones.map((zone) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(zone),
                            selected: _selectedZone == zone,
                            onSelected: (selected) {
                              setState(() => _selectedZone = selected ? zone : null);
                            },
                            selectedColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                            side: BorderSide(color: _selectedZone == zone ? theme.colorScheme.primary : const Color(0xFF333333)),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // CORREÇÃO DE LAYOUT: Passou de Row para Wrap para evitar Overflows
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 3, label: Text('3')),
                            ButtonSegment(value: 5, label: Text('5')),
                            ButtonSegment(value: 10, label: Text('10')),
                            ButtonSegment(value: 0, label: Text('Todas')),
                          ],
                          selected: {_deliveryLimit},
                          onSelectionChanged: (Set<int> newSelection) {
                            setState(() => _deliveryLimit = newSelection.first);
                          },
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                            backgroundColor: Colors.transparent,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Histórico', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(width: 4),
                            Switch(
                              value: _showDelivered,
                              activeThumbColor: theme.colorScheme.secondary,
                              activeTrackColor: theme.colorScheme.secondary.withValues(alpha: 0.5),
                              onChanged: (val) => setState(() => _showDelivered = val),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.format_list_bulleted, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedZone != null ? 'Vista de $_selectedZone' : 'Próximas Entregas', 
                                style: theme.textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (totalItemsPending > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '$totalItemsPending un.',
                            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

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
                        Row(
                          children: [
                            const Icon(Icons.analytics_outlined, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            // Título dinâmico mediante os filtros
                            Expanded(
                              child: Text(
                                _deliveryLimit == 0 
                                    ? (_selectedZone != null ? 'Carga Total Restante (Nesta Zona):' : 'Carga Total Restante na Rota:')
                                    : 'Carga Restante (Próximas $_deliveryLimit Entregas):', 
                                style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                    final stop = displayedStops[index];
                    bool isNear = false;
                    if (widget.currentLocation != null) {
                      final distance = GeoUtils.calculateDistance(
                        widget.currentLocation!.latitude, widget.currentLocation!.longitude,
                        stop.latitude, stop.longitude,
                      );
                      isNear = distance <= 30.0;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: GestureDetector(
                        onTap: () => widget.onStopTap(stop),
                        child: DeliveryCard(
                          clientName: stop.orderName,
                          address: _cleanNotes(stop.notes),
                          products: stop.productsToDeliver,
                          isNear: isNear,
                          imagePath: stop.localImagePath,
                          isDeliveredStatus: stop.isDelivered, 
                          onToggleDelivery: () => widget.onDeliveryToggle(stop.id, !stop.isDelivered),
                          onQuantityAdjust: (prodIdx, isInc) => widget.onProductQuantityAdjust(stop.id, prodIdx, isInc),
                        ),
                      ),
                    );
                  },
                  childCount: displayedStops.length,
                ),
              ),
              
              if (displayedStops.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('Nenhum pedido atende aos filtros atuais.', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}
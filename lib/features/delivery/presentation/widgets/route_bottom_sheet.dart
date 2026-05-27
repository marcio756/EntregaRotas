// Ficheiro: lib/features/delivery/presentation/widgets/route_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/database/collections/route_stop_collection.dart';
import '../../../../core/utils/geo_utils.dart';
import 'delivery_card.dart';

class RouteBottomSheet extends StatefulWidget {
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

  @override
  State<RouteBottomSheet> createState() => _RouteBottomSheetState();
}

class _RouteBottomSheetState extends State<RouteBottomSheet> {
  String? _selectedZone;

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

  Map<String, int> _calculateRemainingTotals(List<RouteStop> stopsToCalculate) {
    final Map<String, int> totals = {};
    for (var stop in stopsToCalculate) {
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

  int _calculateTotalItemsCount(List<RouteStop> stopsToCalculate) {
    int totalUnitCount = 0;
    for (var stop in stopsToCalculate) {
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
    
    // Obter todas as zonas únicas disponíveis
    final availableZones = widget.pendingStops
        .map((s) => _extractZone(s.notes))
        .where((z) => z != null && z.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    // Filtrar a lista visual consoante a seleção
    final displayedStops = widget.pendingStops.where((s) {
      if (_selectedZone == null) return true;
      return _extractZone(s.notes) == _selectedZone;
    }).toList();

    // Os totais agora refletem inteligentemente a Zona que tens selecionada
    final remainingProducts = _calculateRemainingTotals(displayedStops);
    final totalItemsPending = _calculateTotalItemsCount(displayedStops);
    
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
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              
              // Menu Horizontal de Navegação Dinâmica pelas Zonas
              if (availableZones.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        ChoiceChip(
                          label: const Text('Todas', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            side: BorderSide(
                              color: _selectedZone == zone ? theme.colorScheme.primary : const Color(0xFF333333)
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.format_list_bulleted, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            _selectedZone != null ? 'Falta em $_selectedZone (${displayedStops.length})' : 'Próximas Entregas (${displayedStops.length})', 
                            style: theme.textTheme.titleLarge
                          ),
                        ],
                      ),
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
                            Text(
                              _selectedZone != null ? 'Carga Total Restante (Nesta Zona):' : 'Carga Total Restante na Rota:', 
                              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)
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
                          address: _cleanNotes(stop.notes), // Remove a tag da zona da UI do cartão
                          products: stop.productsToDeliver,
                          isNear: isNear,
                          imagePath: stop.localImagePath,
                          onDelivered: () => widget.onDeliveryComplete(stop.id, stop.orderName),
                          onQuantityAdjust: (prodIdx, isInc) => widget.onProductQuantityAdjust(stop.id, prodIdx, isInc),
                        ),
                      ),
                    );
                  },
                  childCount: displayedStops.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
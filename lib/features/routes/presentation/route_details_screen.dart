// Ficheiro: lib/features/routes/presentation/route_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../../core/database/collections/route_stop_collection.dart';
import '../providers/route_stop_provider.dart';
import 'add_order_screen.dart'; 
import 'route_load_sheet_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RouteDetailsScreen extends ConsumerStatefulWidget {
  final DeliveryRoute route;

  const RouteDetailsScreen({super.key, required this.route});

  @override
  ConsumerState<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends ConsumerState<RouteDetailsScreen> {
  int? _selectedStopIndex;

  void _confirmDelete(BuildContext context, WidgetRef ref, RouteStop stop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar Pedido?'),
        content: Text('Tem a certeza que deseja remover o pedido "${stop.orderName}" desta rota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              ref.read(routeStopsProvider(widget.route.id.toString()).notifier).deleteOrder(stop.id);
              if (_selectedStopIndex != null && _selectedStopIndex! == stop.stopOrder) {
                setState(() => _selectedStopIndex = null);
              }
              Navigator.pop(context);
            },
            child: const Text('APAGAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getCumulativeProducts(List<RouteStop> stops, int endIndex) {
    final Map<String, int> totals = {};
    for (int i = 0; i <= endIndex; i++) {
      final stop = stops[i];
      if (!stop.isActive) continue; 
      
      for (var productStr in stop.productsToDeliver) {
        final parts = productStr.split('x ');
        if (parts.length >= 2) {
          final qty = int.tryParse(parts[0]) ?? 0;
          final remainder = parts[1].trim();
          String pureProductInfo = remainder;
          
          if (remainder.contains(' | orig: ')) {
            pureProductInfo = remainder.split(' | orig: ')[0].trim();
          }
          if (qty > 0) {
            totals[pureProductInfo] = (totals[pureProductInfo] ?? 0) + qty;
          }
        }
      }
    }
    return totals;
  }

  Widget _buildCumulativeHeader(List<RouteStop> stops, ThemeData theme) {
    if (_selectedStopIndex == null || _selectedStopIndex! >= stops.length) return const SizedBox.shrink();

    final selectedStop = stops[_selectedStopIndex!];
    final cumulativeTotals = _getCumulativeProducts(stops, _selectedStopIndex!);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Carga necessária até: ${selectedStop.orderName}',
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => setState(() => _selectedStopIndex = null),
              )
            ],
          ),
          const SizedBox(height: 8),
          if (cumulativeTotals.isEmpty)
            const Text('Sem produtos necessários ou cliente inativo.', style: TextStyle(color: Colors.grey))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cumulativeTotals.entries.map((e) => Chip(
                label: Text('${e.value}x ${e.key}', style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: theme.scaffoldBackgroundColor,
                side: const BorderSide(color: Color(0xFF333333)),
              )).toList(),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  String? _extractZone(String? notes) {
    if (notes != null && notes.startsWith('[ZONE:')) {
      final closeIdx = notes.indexOf(']');
      if (closeIdx != -1) return notes.substring(6, closeIdx);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final stops = ref.watch(routeStopsProvider(widget.route.id.toString()));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gerir: ${widget.route.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Guia de Carga Geral',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RouteLoadSheetScreen(
                    activeRoutes: [widget.route], 
                    sessionName: widget.route.name, 
                    sessionIds: widget.route.id.toString(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: stops.isEmpty
          ? Center(
              child: Text(
                'Ainda não existem pedidos nesta rota.',
                style: TextStyle(color: Colors.grey.shade600),
              ).animate().fadeIn().scale(),
            )
          : Column(
              children: [
                _buildCumulativeHeader(stops, theme),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                    itemCount: stops.length,
                    buildDefaultDragHandles: false,
                    onReorder: (oldIndex, newIndex) {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final List<RouteStop> reorderedStops = List.from(stops);
                      final item = reorderedStops.removeAt(oldIndex);
                      reorderedStops.insert(newIndex, item);
                      
                      ref.read(routeStopsProvider(widget.route.id.toString()).notifier).updateStopsOrder(reorderedStops);
                      setState(() => _selectedStopIndex = null);
                    },
                    itemBuilder: (context, index) {
                      final stop = stops[index];
                      final zone = _extractZone(stop.notes);

                      return Dismissible(
                        key: ValueKey(stop.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_sweep, color: Colors.white, size: 32),
                        ),
                        confirmDismiss: (direction) async {
                          _confirmDelete(context, ref, stop);
                          return false; 
                        },
                        child: Card(
                          key: ValueKey('card_${stop.id}'),
                          margin: const EdgeInsets.only(bottom: 12),
                          color: stop.isActive 
                              ? theme.cardTheme.color 
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: _selectedStopIndex == index ? theme.colorScheme.primary : const Color(0xFF2C2C2C),
                              width: _selectedStopIndex == index ? 1.5 : 1.0,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: stop.isActive 
                                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.2),
                              child: Text('${index + 1}', style: TextStyle(color: stop.isActive ? theme.colorScheme.primary : Colors.grey, fontWeight: FontWeight.bold)),
                            ),
                            title: Row(
                              children: [
                                if (zone != null) 
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: stop.isActive ? 0.9 : 0.4),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(zone, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                Expanded(
                                  child: Text(
                                    stop.orderName, 
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: stop.isActive ? Colors.white : Colors.grey,
                                      decoration: stop.isActive ? null : TextDecoration.lineThrough,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              stop.productsToDeliver.join(', '), 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: stop.isActive ? Colors.grey : Colors.grey.shade700),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedStopIndex = _selectedStopIndex == index ? null : index;
                              });
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: stop.isActive,
                                  activeThumbColor: theme.colorScheme.primary,
                                  onChanged: (val) {
                                    ref.read(routeStopsProvider(widget.route.id.toString()).notifier).toggleActiveStatus(stop.id, val);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AddOrderScreen(
                                          activeRoute: widget.route,
                                          orderToEdit: stop,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Icon(Icons.drag_indicator, color: Colors.grey, size: 28),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddOrderScreen(activeRoute: widget.route),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('NOVO PEDIDO', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
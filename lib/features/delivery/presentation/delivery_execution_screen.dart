// Ficheiro: lib/features/delivery/presentation/delivery_execution_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../routes/providers/route_stop_provider.dart';
import 'widgets/delivery_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'daily_summary_screen.dart';
import 'delivery_map_screen.dart';
import '../../../core/presentation/widgets/skeleton_loader.dart';

class DeliveryExecutionScreen extends ConsumerStatefulWidget {
  final DeliveryRoute activeRoute;

  const DeliveryExecutionScreen({super.key, required this.activeRoute});

  @override
  ConsumerState<DeliveryExecutionScreen> createState() => _DeliveryExecutionScreenState();
}

class _DeliveryExecutionScreenState extends ConsumerState<DeliveryExecutionScreen> {
  Position? _currentLocation;
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLocating = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLocating = false);
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentLocation = position;
          _isLocating = false;
        });
      }
    }).onError((error) {
      if (mounted) setState(() => _isLocating = false);
    });
  }

  void _handleDeliveryComplete(int stopId, String orderName) {
    ref.read(routeStopsProvider(widget.activeRoute.id).notifier).toggleDeliveryStatus(stopId, true);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$orderName entregue com sucesso.'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'DESFAZER',
          textColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            ref.read(routeStopsProvider(widget.activeRoute.id).notifier).toggleDeliveryStatus(stopId, false);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stops = ref.watch(routeStopsProvider(widget.activeRoute.id));
    final pendingStops = stops.where((s) => !s.isDelivered).toList();

    Map<String, int> totalLoadByProduct = {};
    for (var stop in stops) {
      for (var item in stop.productsToDeliver) {
        final parts = item.split('x ');
        if (parts.length == 2) {
          final qty = int.tryParse(parts[0]) ?? 0;
          final name = parts[1].trim();
          totalLoadByProduct[name] = (totalLoadByProduct[name] ?? 0) + qty;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rota em Curso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(widget.activeRoute.name, style: TextStyle(fontSize: 14, color: theme.colorScheme.primary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DeliveryMapScreen(activeRoute: widget.activeRoute),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          if (totalLoadByProduct.isNotEmpty)
            Container(
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Carga Total da Rota (${stops.length} pedidos):', 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: totalLoadByProduct.keys.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        String productName = totalLoadByProduct.keys.elementAt(index);
                        int totalQty = totalLoadByProduct[productName]!;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Text('$totalQty', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
          const Divider(height: 1, thickness: 1, color: Color(0xFF2C2C2C)),

          Expanded(
            child: _isLocating 
              ? ListView.builder(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: 4,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: SkeletonLoader(height: 140),
                  ),
                )
              : pendingStops.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 80, color: theme.colorScheme.secondary)
                          .animate().scale().fadeIn(),
                        const SizedBox(height: 16),
                        const Text('Todas as entregas concluídas!').animate().fadeIn().slideY(),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => DailySummaryScreen(activeRoute: widget.activeRoute),
                            ),
                          ),
                          icon: const Icon(Icons.bar_chart),
                          label: const Text('VER RESUMO DO DIA', style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 12),
                    itemCount: pendingStops.length,
                    itemBuilder: (context, index) {
                      final stop = pendingStops[index];

                      bool isNear = false;
                      if (_currentLocation != null) {
                        // Calcula a distância diretamente com os dados embutidos na paragem
                        final distance = Geolocator.distanceBetween(
                          _currentLocation!.latitude, _currentLocation!.longitude,
                          stop.latitude, stop.longitude,
                        );
                        isNear = distance <= 30.0;
                      }

                      return DeliveryCard(
                        clientName: stop.orderName,
                        address: stop.notes ?? 'Sem notas adicionais',
                        productsSummary: stop.productsToDeliver.join(', '),
                        isNear: isNear,
                        onDelivered: () => _handleDeliveryComplete(stop.id, stop.orderName),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
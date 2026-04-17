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

  void _handleDeliveryComplete(int stopId, String clientName) {
    // 1. Persists the completion state to the database via Provider
    ref.read(routeStopsProvider(widget.activeRoute.id).notifier).toggleDeliveryStatus(stopId, true);

    // 2. Shows the feedback with the integrated Undo functionality
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$clientName entregue.'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'DESFAZER',
          textColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            // Reverts the delivery state in the database
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

    // Motor de Cálculo: Somatório do stock necessário para a rota atual
    Map<String, int> productTotals = {};
    for (var stop in pendingStops) {
      for (var item in stop.productsToDeliver) {
        final parts = item.split('x ');
        if (parts.length == 2) {
          final qty = int.tryParse(parts[0]) ?? 0;
          final name = parts[1].trim();
          productTotals[name] = (productTotals[name] ?? 0) + qty;
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
                // Injetamos a Rota Ativa no Mapa
                builder: (context) => DeliveryMapScreen(activeRoute: widget.activeRoute),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Banner de Stock Necessário
          if (productTotals.isNotEmpty)
            Container(
              width: double.infinity,
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Carga Necessária para Terminar:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: productTotals.keys.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        String productName = productTotals.keys.elementAt(index);
                        int totalQty = productTotals[productName]!;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Text('$totalQty', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
          const Divider(height: 1, color: Color(0xFF333333)),

          // Lista de Entregas
          Expanded(
            child: _isLocating 
              ? ListView.builder(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: 4, // Skeleton Illusions
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
                        const Text('Todas as entregas concluídas!').animate().fadeIn().scale(),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const DailySummaryScreen()),
                          ),
                          child: const Text('VER RESUMO DO DIA', style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: pendingStops.length,
                    itemBuilder: (context, index) {
                      final stop = pendingStops[index];
                      final client = stop.clientPoint.value;
                      if (client == null) return const SizedBox.shrink();

                      bool isNear = false;
                      if (_currentLocation != null) {
                        final distance = Geolocator.distanceBetween(
                          _currentLocation!.latitude, _currentLocation!.longitude,
                          client.latitude, client.longitude,
                        );
                        isNear = distance <= 30.0;
                      }

                      return DeliveryCard(
                        clientName: client.clientName,
                        address: client.deliveryNotes ?? 'Sem notas de entrega',
                        productsSummary: stop.productsToDeliver.join(', '),
                        isNear: isNear,
                        onDelivered: () => _handleDeliveryComplete(stop.id, client.clientName),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
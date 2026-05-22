// Ficheiro: lib/features/delivery/presentation/delivery_execution_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../../core/database/collections/route_stop_collection.dart';
import '../../routes/providers/route_stop_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'daily_summary_screen.dart';
import '../../../core/presentation/widgets/skeleton_loader.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../core/utils/ui_utils.dart';
import '../../routes/presentation/order_details_screen.dart';
import 'widgets/route_bottom_sheet.dart';

class DeliveryExecutionScreen extends ConsumerStatefulWidget {
  final List<DeliveryRoute> activeRoutes;
  final String sessionName;
  final String sessionIds;

  const DeliveryExecutionScreen({
    super.key, 
    required this.activeRoutes,
    required this.sessionName,
    required this.sessionIds,
  });

  @override
  ConsumerState<DeliveryExecutionScreen> createState() => _DeliveryExecutionScreenState();
}

class _DeliveryExecutionScreenState extends ConsumerState<DeliveryExecutionScreen> {
  Position? _currentLocation;
  bool _isLocating = true;
  final MapController _mapController = MapController();
  final Set<int> _ignoredGeofenceIds = {};

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); 
    _startLocationTracking();
  }

  @override
  void dispose() {
    WakelockPlus.disable(); 
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLocating = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLocating = false);
        return;
      }
    }

    final lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null && mounted) {
      setState(() {
        _currentLocation = lastPosition;
        _isLocating = false;
      });
      _mapController.move(LatLng(lastPosition.latitude, lastPosition.longitude), 17.5);
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 8),
    ).listen((Position position) {
      if (position.accuracy > 15.0) return;

      if (_currentLocation != null) {
        final deltaDistance = GeoUtils.calculateDistance(
          _currentLocation!.latitude, _currentLocation!.longitude,
          position.latitude, position.longitude,
        );
        if (deltaDistance < 4.0) return;
      }

      if (mounted) {
        setState(() {
          if (_currentLocation == null || lastPosition == null) {
            _mapController.move(LatLng(position.latitude, position.longitude), 17.5);
          }
          _currentLocation = position;
          _isLocating = false;
        });

        _evaluateAutoDeliveryTrigger(position);
      }
    }).onError((error) {
      if (mounted) setState(() => _isLocating = false);
    });
  }

  void _evaluateAutoDeliveryTrigger(Position position) {
    // Busca apenas as paragens ATIVAS antes de aplicar os cálculos de Geofencing
    final stops = ref.read(routeStopsProvider(widget.sessionIds)).where((s) => s.isActive).toList();
    final pendingStops = stops.where((s) => !s.isDelivered).toList();

    for (var stop in pendingStops) {
      if (_ignoredGeofenceIds.contains(stop.id)) continue;

      final distance = GeoUtils.calculateDistance(position.latitude, position.longitude, stop.latitude, stop.longitude);

      if (distance <= 25.0) {
        _ignoredGeofenceIds.add(stop.id);
        HapticFeedback.lightImpact();
        
        ref.read(routeStopsProvider(widget.sessionIds).notifier).toggleDeliveryStatus(stop.id, true);
        
        UiUtils.showUndoToast(
          context, '${stop.orderName} marcado como Entregue (Automático).', 
          () {
            _ignoredGeofenceIds.remove(stop.id);
            ref.read(routeStopsProvider(widget.sessionIds).notifier).toggleDeliveryStatus(stop.id, false);
          }
        );
        break;
      }
    }
  }

  void _handleDeliveryComplete(int stopId, String orderName) {
    ref.read(routeStopsProvider(widget.sessionIds).notifier).toggleDeliveryStatus(stopId, true);
    UiUtils.showUndoToast(context, '$orderName entregue com sucesso.', () {
      ref.read(routeStopsProvider(widget.sessionIds).notifier).toggleDeliveryStatus(stopId, false);
    });
  }

  void _triggerDrillTransition(RouteStop stop) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => OrderDetailsScreen(stop: stop),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Ignorar por completo os pedidos inativos durante a fase de condução
    final stops = ref.watch(routeStopsProvider(widget.sessionIds)).where((s) => s.isActive).toList();
    final pendingStops = stops.where((s) => !s.isDelivered).toList();

    if (!_isLocating && pendingStops.isEmpty && stops.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 80, color: theme.colorScheme.secondary).animate().scale().fadeIn(),
              const SizedBox(height: 16),
              const Text('Todas as entregas concluídas!').animate().fadeIn().slideY(),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => DailySummaryScreen(activeRoutes: widget.activeRoutes, sessionName: widget.sessionName, sessionIds: widget.sessionIds)),
                ),
                icon: const Icon(Icons.bar_chart),
                label: const Text('VER RESUMO DO DIA', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      );
    }

    final List<Marker> mapMarkers = pendingStops.map((stop) {
      return Marker(
        key: ValueKey(stop.id), point: LatLng(stop.latitude, stop.longitude), width: 80, height: 80, alignment: Alignment.center, 
        child: GestureDetector(
          onTap: () => _triggerDrillTransition(stop), behavior: HitTestBehavior.opaque, 
          child: Stack(
            alignment: Alignment.center, clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 40,
                child: Icon(
                  Icons.location_on, color: theme.colorScheme.primary, size: 50,
                  shadows: const [Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2, 2))],
                ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 2.seconds),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.sessionName, style: const TextStyle(shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amber, shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
            tooltip: 'Otimizar Ordem de Entrega',
            onPressed: () {
              if (_currentLocation != null) {
                ref.read(routeStopsProvider(widget.sessionIds).notifier)
                   .optimizePendingStops(_currentLocation!.latitude, _currentLocation!.longitude);
                UiUtils.showUndoToast(context, 'Plano reorganizado pela distância mais curta!', () {});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A aguardar localização GPS...')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.flag, color: Colors.white, shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
            tooltip: 'Finalizar Manualmente',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Terminar Sessão Manualmente?'),
                  content: Text(pendingStops.isNotEmpty 
                      ? 'Ainda faltam ${pendingStops.length} entregas. Tem a certeza que deseja dar por terminada e ir para o resumo?'
                      : 'Deseja avançar para o resumo do dia?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => DailySummaryScreen(activeRoutes: widget.activeRoutes, sessionName: widget.sessionName, sessionIds: widget.sessionIds)));
                      },
                      child: const Text('TERMINAR', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(initialCenter: LatLng(39.3999, -8.2245), initialZoom: 16.0),
            children: [
              TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', userAgentPackageName: 'com.pao.rota_app', maxNativeZoom: 20, maxZoom: 22, keepBuffer: 3),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_currentLocation!.latitude, _currentLocation!.longitude), width: 60, height: 60, alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.3), shape: BoxShape.circle, border: Border.all(color: Colors.blue, width: 2)),
                        child: const Icon(Icons.drive_eta, color: Colors.blueAccent, size: 28),
                      ),
                    ),
                  ],
                ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45, size: const Size(50, 50), alignment: Alignment.center, padding: const EdgeInsets.all(50), maxZoom: 20, markers: mapMarkers,
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black54, offset: Offset(0, 4))]),
                      child: Center(child: Text(markers.length.toString(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18))),
                    );
                  },
                ),
              ),
            ],
          ),
          
          if (_isLocating) const SkeletonLoader(height: double.infinity, borderRadius: 0),
            
          if (!_isLocating && pendingStops.isNotEmpty)
            RouteBottomSheet(
              pendingStops: pendingStops,
              currentLocation: _currentLocation,
              onDeliveryComplete: _handleDeliveryComplete,
              onStopTap: _triggerDrillTransition,
              onProductQuantityAdjust: (stopId, prodIdx, isInc) {
                ref.read(routeStopsProvider(widget.sessionIds).notifier).adjustProductQuantity(stopId, prodIdx, isInc);
              },
            ),
        ],
      ),
    );
  }
}
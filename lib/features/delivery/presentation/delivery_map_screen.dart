// Ficheiro: lib/features/delivery/presentation/delivery_map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart'; 
import 'dart:io';
import '../../../core/database/collections/route_collection.dart';
import '../../../core/database/collections/route_stop_collection.dart';
import '../../routes/providers/route_stop_provider.dart';
import '../../routes/presentation/add_order_screen.dart';
import '../../../core/presentation/widgets/skeleton_loader.dart';

class DeliveryMapScreen extends ConsumerStatefulWidget {
  final List<DeliveryRoute> activeRoutes;
  final String sessionName;
  final String sessionIds;

  const DeliveryMapScreen({
    super.key, 
    required this.activeRoutes,
    required this.sessionName,
    required this.sessionIds,
  });

  @override
  ConsumerState<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends ConsumerState<DeliveryMapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(39.3999, -8.2245);
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _centerOnUserLocation();
  }

  Future<void> _centerOnUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _isLoadingLocation = false);
          return;
        }
      }

      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null && mounted) {
        setState(() {
          _currentCenter = LatLng(lastPos.latitude, lastPos.longitude);
          _isLoadingLocation = false;
        });
        _mapController.move(_currentCenter, 18.0);
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final newLatLng = LatLng(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _currentCenter = newLatLng;
          _isLoadingLocation = false;
        });
        _mapController.move(newLatLng, 18.0); 
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _showStopDetails(RouteStop stop) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final theme = Theme.of(context);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_pin_circle, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Text(stop.orderName, style: theme.textTheme.titleLarge)),
                  if (stop.isDelivered)
                    Chip(label: const Text('Entregue', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: theme.colorScheme.secondary)
                ],
              ),
              const SizedBox(height: 8),
              Text(stop.notes ?? 'Sem notas de entrega específicas.', style: TextStyle(color: Colors.grey.shade400)),
              
              if (stop.localImagePath != null) ...[
                const SizedBox(height: 16),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: FileImage(File(stop.localImagePath!)), fit: BoxFit.cover),
                  ),
                ),
              ],

              const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Divider(color: Color(0xFF2C2C2C))),
              Text('Produtos a Entregar', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (stop.productsToDeliver.isEmpty)
                const Text('Nenhum produto associado.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: stop.productsToDeliver.map((product) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF333333)),
                      ),
                      child: Text(product, style: const TextStyle(fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showClusterDetails(List<Marker> markers) {
    final stops = markers.map((m) => (m.key as ValueKey<RouteStop>).value).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.layers, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text('${stops.length} Pedidos Próximos', style: theme.textTheme.titleLarge),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF2C2C2C)),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: stops.length,
                  itemBuilder: (context, index) {
                    final stop = stops[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: stop.isDelivered ? Colors.grey.shade800 : theme.colorScheme.primary.withValues(alpha: 0.2),
                        child: Icon(stop.isDelivered ? Icons.check : Icons.location_on, color: stop.isDelivered ? Colors.grey : theme.colorScheme.primary),
                      ),
                      title: Text(stop.orderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(stop.productsToDeliver.join(', '), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        Navigator.pop(context);
                        _showStopDetails(stop); 
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  void _promptTargetRouteForNewOrder() {
    if (widget.activeRoutes.length == 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddOrderScreen(activeRoute: widget.activeRoutes.first)));
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Adicionar a qual Rota?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.activeRoutes.map((route) => ListTile(
              leading: const Icon(Icons.route),
              title: Text(route.name),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddOrderScreen(activeRoute: route)));
              },
            )).toList(),
          ),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Filtro crucial para que o cluster do mapa represente apenas trabalhos ativos
    final stops = ref.watch(routeStopsProvider(widget.sessionIds)).where((s) => s.isActive).toList();

    final List<Marker> clientMarkers = stops.map((stop) {
      return Marker(
        key: ValueKey(stop),
        point: LatLng(stop.latitude, stop.longitude),
        width: 80, height: 80,
        alignment: Alignment.center, 
        child: GestureDetector(
          onTap: () => _showStopDetails(stop),
          behavior: HitTestBehavior.opaque, 
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 40,
                child: Icon(
                  Icons.location_on,
                  color: stop.isDelivered ? Colors.grey.shade700 : theme.colorScheme.primary,
                  size: 50,
                  shadows: const [Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2, 2))],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa: ${widget.sessionName}'),
        actions: [
          IconButton(icon: const Icon(Icons.my_location), onPressed: _centerOnUserLocation),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.pao.rota_app',
                maxNativeZoom: 20,
                maxZoom: 22,
              ),
              MarkerLayer(
                markers: [
                  if (!_isLoadingLocation)
                    Marker(
                      point: _currentCenter,
                      width: 60, height: 60,
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: const Icon(Icons.drive_eta, color: Colors.blueAccent, size: 28),
                      ),
                    ),
                ],
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45, 
                  size: const Size(50, 50),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  maxZoom: 20, 
                  markers: clientMarkers,
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black54, offset: Offset(0, 4))]
                      ),
                      child: Center(
                        child: Text(markers.length.toString(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    );
                  },
                  onClusterTap: (clusterNode) {
                    _showClusterDetails(clusterNode.markers);
                  },
                ),
              ),
            ],
          ),
          
          if (_isLoadingLocation)
            const SkeletonLoader(height: double.infinity, borderRadius: 0),
            
          Positioned(
            bottom: 32, right: 24,
            child: FloatingActionButton.extended(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.black,
              onPressed: _promptTargetRouteForNewOrder,
              icon: const Icon(Icons.add_location_alt),
              label: const Text('NOVO PEDIDO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
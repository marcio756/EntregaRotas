// Ficheiro: lib/features/delivery/presentation/delivery_map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../../core/database/collections/route_stop_collection.dart';
import '../../routes/providers/route_stop_provider.dart';
import '../../clients/presentation/add_client_point_screen.dart';
import '../../../core/presentation/widgets/skeleton_loader.dart';

class DeliveryMapScreen extends ConsumerStatefulWidget {
  final DeliveryRoute activeRoute;

  const DeliveryMapScreen({super.key, required this.activeRoute});

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

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLatLng = LatLng(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _currentCenter = newLatLng;
          _isLoadingLocation = false;
        });
        _mapController.move(newLatLng, 16.0); 
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  /// Displays an intuitive bottom sheet with the delivery details when a marker is tapped
  /// @param {RouteStop} stop - The route stop associated with the tapped marker
  void _showStopDetails(RouteStop stop) {
    final client = stop.clientPoint.value;
    if (client == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_pin_circle, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(client.clientName, style: theme.textTheme.titleLarge),
                  ),
                  if (stop.isDelivered)
                    Chip(
                      label: const Text('Entregue', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      backgroundColor: theme.colorScheme.secondary,
                    )
                ],
              ),
              const SizedBox(height: 8),
              Text(client.deliveryNotes ?? 'Sem notas de entrega específicas.', style: TextStyle(color: Colors.grey.shade400)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: Color(0xFF2C2C2C)),
              ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Escuta todas as paragens da rota em tempo real para desenhar os clientes
    final stops = ref.watch(routeStopsProvider(widget.activeRoute.id));

    final List<Marker> clientMarkers = stops.where((s) => s.clientPoint.value != null).map((stop) {
      final client = stop.clientPoint.value!;
      return Marker(
        point: LatLng(client.latitude, client.longitude),
        width: 60, // Aumento da área de toque para melhor precisão (User-Friendly Design)
        height: 60,
        child: GestureDetector(
          onTap: () => _showStopDetails(stop),
          behavior: HitTestBehavior.opaque,
          child: Icon(
            Icons.location_on,
            color: stop.isDelivered ? Colors.grey.shade700 : theme.colorScheme.primary,
            size: 40,
            shadows: const [
              Shadow(blurRadius: 10.0, color: Colors.black54, offset: Offset(2, 2)),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa: ${widget.activeRoute.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnUserLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.pao.rota_app',
              ),
              MarkerLayer(
                markers: [
                  ...clientMarkers,
                  if (!_isLoadingLocation)
                    Marker(
                      point: _currentCenter,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_shipping, color: Colors.blue, size: 28),
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          if (_isLoadingLocation)
            const SkeletonLoader(height: double.infinity, borderRadius: 0),
            
          Positioned(
            bottom: 32,
            right: 24,
            child: FloatingActionButton.extended(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.black,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddClientPointScreen(activeRoute: widget.activeRoute)),
                );
              },
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('NOVO CLIENTE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
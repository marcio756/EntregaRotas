import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/collections/route_collection.dart';
import '../../routes/providers/route_stop_provider.dart';
import '../../clients/presentation/add_client_point_screen.dart';

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
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Escuta todas as paragens da rota em tempo real para desenhar os clientes
    final stops = ref.watch(routeStopsProvider(widget.activeRoute.id));

    final List<Marker> clientMarkers = stops.where((s) => s.clientPoint.value != null).map((stop) {
      final client = stop.clientPoint.value!;
      return Marker(
        point: LatLng(client.latitude, client.longitude),
        width: 40,
        height: 40,
        child: Icon(
          Icons.location_on,
          color: stop.isDelivered ? Colors.grey : theme.colorScheme.primary,
          size: 36,
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
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 32,
            right: 24,
            child: FloatingActionButton.extended(
              backgroundColor: theme.colorScheme.secondary,
              onPressed: () {
                // Passamos a Rota Ativa para o formulário de cliente
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddClientPointScreen(activeRoute: widget.activeRoute)),
                );
              },
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
              label: const Text('NOVO CLIENTE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
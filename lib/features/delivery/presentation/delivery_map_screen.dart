import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import '../../clients/presentation/add_client_point_screen.dart';

class DeliveryMapScreen extends StatelessWidget {
  const DeliveryMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Entrega')),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(41.1579, -8.6291), // Porto como exemplo
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.pao.rota_app',
              ),
              // Aqui aparecerão os Pins dos clientes automaticamente no futuro
              const MarkerLayer(markers: []),
            ],
          ),
          Positioned(
            bottom: 32,
            right: 24,
            child: FloatingActionButton.extended(
              backgroundColor: theme.colorScheme.secondary,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddClientPointScreen()),
                );
              },
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
              label: const Text('NOVO CLIENTE', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
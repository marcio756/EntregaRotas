import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/presentation/widgets/skeleton_loader.dart';

class PickedLocationData {
  final LatLng coordinates;
  final String captureMethod;

  PickedLocationData({required this.coordinates, required this.captureMethod});
}

class InteractiveMapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const InteractiveMapPickerScreen({super.key, this.initialLocation});

  @override
  State<InteractiveMapPickerScreen> createState() => _InteractiveMapPickerScreenState();
}

class _InteractiveMapPickerScreenState extends State<InteractiveMapPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(39.3999, -8.2245);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMapCenter();
  }

  Future<void> _initializeMapCenter() async {
    if (widget.initialLocation != null) {
      setState(() {
        _currentCenter = widget.initialLocation!;
        _isLoading = false;
      });
      return;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          if (mounted) {
            setState(() {
              _currentCenter = LatLng(position.latitude, position.longitude);
              _isLoading = false;
            });
          }
          return;
        }
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  void _confirmLocation() {
    final result = PickedLocationData(
      coordinates: _currentCenter,
      captureMethod: 'INTERACTIVE_MAP',
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Satélite: Marcar Casa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? const SkeletonLoader(height: double.infinity, borderRadius: 0)
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentCenter,
                    initialZoom: 19.0,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture) {
                        setState(() => _currentCenter = position.center);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                      userAgentPackageName: 'com.pao.rota_app',
                      maxNativeZoom: 20,
                      maxZoom: 22,
                    ),
                  ],
                ),
                
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Icon(
                      Icons.location_pin,
                      size: 56,
                      color: theme.colorScheme.primary,
                      shadows: const [
                        Shadow(blurRadius: 12.0, color: Colors.black, offset: Offset(0, 4)),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 40,
                  left: 24,
                  right: 24,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.black,
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _confirmLocation,
                      icon: const Icon(Icons.check),
                      label: const Text('CONFIRMAR COORDENADA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(),
                ),
              ],
            ),
    );
  }
}
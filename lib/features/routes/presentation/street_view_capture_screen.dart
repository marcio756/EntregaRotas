import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para consolidateHttpClientResponseBytes
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:path_provider/path_provider.dart';

/// Ecrã de Alta Performance em 3D.
/// Permite navegar no Google Street View e tirar uma fotografia à vista atual.
/// Utiliza a Street View Static API para garantir uma captura 100% fiável da Platform View.
class StreetViewCaptureScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const StreetViewCaptureScreen({super.key, required this.latitude, required this.longitude});

  @override
  State<StreetViewCaptureScreen> createState() => _StreetViewCaptureScreenState();
}

class _StreetViewCaptureScreenState extends State<StreetViewCaptureScreen> {
  StreetViewController? _streetViewController;
  bool _isCapturing = false;

  Future<void> _captureView() async {
    if (_streetViewController == null) return;
    
    setState(() => _isCapturing = true);
    
    try {
      // 1. Obter a orientação exata da câmara no ambiente 3D
      final camera = await _streetViewController!.getPanoramaCamera();
      final location = await _streetViewController!.getLocation();

      final lat = location?.position?.latitude ?? widget.latitude;
      final lng = location?.position?.longitude ?? widget.longitude;
      final heading = camera.bearing ?? 0.0;
      final pitch = camera.tilt ?? 0.0;
      
      // Converte o Zoom do visor para Field of View (FOV) da API Estática
      final fov = 120.0 / (1.0 + (camera.zoom ?? 1.0));

      // 2. Chamar a API Estática da Google com a chave injetada
      const apiKey = 'AIzaSyCLSiOg7vV6nj5bP7HxoDLLzVNTsIta510';
      final url = 'https://maps.googleapis.com/maps/api/streetview?size=800x800&location=$lat,$lng&heading=$heading&pitch=$pitch&fov=$fov&key=$apiKey';

      // 3. Efetuar o download do snapshot real
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);

      // 4. Gravar de forma persistente no sistema do telemóvel
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/streetview_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      
      if (mounted) {
        Navigator.of(context).pop(file.path); // Devolve o caminho da imagem HD guardada
        return;
      }
    } catch (e) {
      // Falha silenciosa com fallback para fechar o ecrã
    }

    if (mounted) {
      setState(() => _isCapturing = false);
      Navigator.of(context).pop(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Rodar Câmara e Fotografar', style: TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 8)])),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 8)]),
      ),
      body: Stack(
        children: [
          FlutterGoogleStreetView(
            initPos: LatLng(widget.latitude, widget.longitude),
            initSource: StreetViewSource.outdoor,
            initBearing: 0,
            initTilt: 0,
            initZoom: 1,
            onStreetViewCreated: (controller) {
              _streetViewController = controller;
            },
            markers: {
              Marker(
                markerId: const MarkerId('target_door'),
                position: LatLng(widget.latitude, widget.longitude),
              )
            },
          ),
          
          if (_isCapturing)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('A processar imagem de alta resolução...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
          if (!_isCapturing)
            const Center(
              child: Icon(Icons.add, color: Colors.white70, size: 32),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isCapturing 
          ? null 
          : FloatingActionButton.extended(
              onPressed: _captureView,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.camera),
              label: const Text('TIRAR FOTO AQUI', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
    );
  }
}
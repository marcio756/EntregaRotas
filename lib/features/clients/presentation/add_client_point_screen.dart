import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Screen responsible for creating a new Client Point.
/// Captures exact GPS coordinates (Pinpoint) for future geofencing routing.
class AddClientPointScreen extends StatefulWidget {
  const AddClientPointScreen({super.key});

  @override
  State<AddClientPointScreen> createState() => _AddClientPointScreenState();
}

class _AddClientPointScreenState extends State<AddClientPointScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();
  
  Position? _capturedPosition;
  bool _isCapturingGPS = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Requests permissions and captures the current exact GPS location.
  /// Uses a Progress Illusion to reassure the user during the hardware delay.
  Future<void> _captureLocation() async {
    setState(() {
      _isCapturingGPS = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada.');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        _capturedPosition = position;
        _isCapturingGPS = false;
      });
    } catch (e) {
      setState(() {
        _isCapturingGPS = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao capturar GPS: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _saveClientPoint() {
    if (_formKey.currentState!.validate()) {
      if (_capturedPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('É obrigatório capturar a localização (GPS).')),
        );
        return;
      }
      
      // Future integration: Save to Isar Database via Riverpod.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ponto de Cliente guardado com sucesso!')),
      );
      Navigator.pop(context); // Continuity Transition back to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Ponto de Entrega', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dados do Cliente', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Nome do Cliente / Local',
                icon: Icons.person_outline,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _contactController,
                label: 'Contacto (Opcional)',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _notesController,
                label: 'Notas de Entrega (ex: Deixar no portão)',
                icon: Icons.note_alt_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              
              Text('Localização Exata (Pinpoint)', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
              const SizedBox(height: 16),
              _buildGPSCaptureCard(theme),
              
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56, // Large touch target
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _saveClientPoint,
                  child: const Text(
                    'Guardar Ponto de Entrega',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to render standardized inputs.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: isRequired 
          ? (value) => value != null && value.isEmpty ? 'Campo obrigatório' : null 
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
      ),
    );
  }

  /// Builds the interactive GPS capture zone.
  Widget _buildGPSCaptureCard(ThemeData theme) {
    return InkWell(
      onTap: _isCapturingGPS ? null : _captureLocation,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Resolved the deprecation warning using withValues(alpha: ...)
          color: _capturedPosition != null 
              ? theme.colorScheme.secondary.withValues(alpha: 0.1) 
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _capturedPosition != null 
                ? theme.colorScheme.secondary 
                : const Color(0xFF333333),
          ),
        ),
        child: Column(
          children: [
            if (_isCapturingGPS)
              const CircularProgressIndicator().animate().fadeIn()
            else if (_capturedPosition != null)
              Column(
                children: [
                  Icon(Icons.check_circle, color: theme.colorScheme.secondary, size: 40)
                      .animate().scale(duration: 300.ms),
                  const SizedBox(height: 8),
                  Text('Coordenadas Registadas', style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                  Text(
                    'Lat: ${_capturedPosition!.latitude.toStringAsFixed(5)}, Lng: ${_capturedPosition!.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Icon(Icons.gps_fixed, color: theme.colorScheme.primary, size: 40),
                  const SizedBox(height: 8),
                  const Text('Tocar para capturar GPS atual'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
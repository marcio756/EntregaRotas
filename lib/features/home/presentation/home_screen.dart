
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../delivery/presentation/delivery_map_screen.dart';

/// The primary landing page of the application.
/// Focuses on the "Start Working" action to initiate the delivery route.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bakery_dining, size: 80, color: theme.colorScheme.primary)
                .animate().fadeIn().scale(),
            const SizedBox(height: 24),
            Text(
              'Distribuição de Pão',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Text('Pronto para a rota de hoje?', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 64),
            
            // "Começar a Trabalhar" Button - The heart of the app
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => _startWorkFlow(context),
                icon: const Icon(Icons.play_arrow_rounded, size: 32),
                label: const Text('COMEÇAR A TRABALHAR', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ).animate().shimmer(delay: 1.seconds, duration: 2.seconds),
          ],
        ),
      ),
    );
  }

  /// Orchestrates the transition from Home to Route Selection/Execution.
  void _startWorkFlow(BuildContext context) {
    // For now, we transition directly to the Map Execution Screen.
    // In the next step, we will add a BottomSheet to select existing routes.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DeliveryMapScreen()),
    );
  }
}
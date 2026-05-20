// Ficheiro: lib/features/routes/presentation/order_details_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/database/collections/route_stop_collection.dart';
import '../../../core/presentation/widgets/skeleton_loader.dart';

/// Screen presenting granular details of a specific delivery order.
/// Incorporates HTTP simulation and local file loading via Skeleton Screens.
class OrderDetailsScreen extends StatelessWidget {
  final RouteStop stop;

  const OrderDetailsScreen({super.key, required this.stop});

  Widget _buildDynamicImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SkeletonLoader(height: double.infinity, borderRadius: 0);
        },
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(stop.orderName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: stop.localImagePath != null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stop.localImagePath != null)
              SizedBox(
                height: 300,
                width: double.infinity,
                child: Hero(
                  tag: 'image_${stop.id}',
                  child: _buildDynamicImage(stop.localImagePath!),
                ),
              )
            else
              const SafeArea(child: SizedBox(height: 16)),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: theme.colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(child: Text(stop.orderName, style: theme.textTheme.headlineMedium)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    stop.notes ?? 'Sem notas ou indicações específicas para esta entrega.',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Divider(color: Color(0xFF2C2C2C)),
                  ),
                  Text('Produtos a Entregar', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  if (stop.productsToDeliver.isEmpty)
                    const Text('Nenhum produto listado.', style: TextStyle(color: Colors.grey))
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: stop.productsToDeliver.map((product) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF333333)),
                          ),
                          child: Text(product, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Ficheiro: lib/features/delivery/presentation/widgets/delivery_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Represents a single delivery stop in the route execution list.
/// Encapsulates the explicit actions, interactive product quantity adjustments,
/// and Geofencing highlight logic to maintain Single Responsibility.
class DeliveryCard extends StatelessWidget {
  final String clientName;
  final String address;
  final List<String> products;
  final bool isNear; // Triggered by Geofencing
  final VoidCallback onDelivered;
  final Function(int productIndex, bool isIncrement) onQuantityAdjust;

  const DeliveryCard({
    super.key,
    required this.clientName,
    required this.address,
    required this.products,
    required this.isNear,
    required this.onDelivered,
    required this.onQuantityAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(clientName),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        // Optimistic UI callback triggered instantly on swipe completion.
        onDelivered();
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 32),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          // Highlights the card if the user is within the geofence boundary.
          side: isNear 
              ? BorderSide(color: theme.colorScheme.primary, width: 2)
              : const BorderSide(color: Color(0xFF333333), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Large touch targets
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      clientName,
                      style: theme.textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isNear)
                    const Icon(Icons.location_on, color: Color(0xFF64FFDA))
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 1500.ms),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: Color(0xFF333333)),
              ),
              
              // Interactive product list panel with quick +/- buttons
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, idx) {
                  final itemStr = products[idx];
                  
                  // Extract display representation
                  final displayStr = itemStr.split(' | orig: ')[0];
                  final lineParts = displayStr.split('x ');
                  final qty = lineParts[0];
                  final nameAndCat = lineParts.length == 2 ? lineParts[1] : displayStr;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.bakery_dining_outlined, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            nameAndCat,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 22),
                              onPressed: () => onQuantityAdjust(idx, false),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 30),
                              alignment: Alignment.center,
                              child: Text(
                                qty,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.add_circle_outline, color: Colors.amber, size: 22),
                              onPressed: () => onQuantityAdjust(idx, true),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              // Explicit action button providing an alternative approach to the gesture swipe.
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.secondary.withValues(alpha: 0.5)),
                    foregroundColor: theme.colorScheme.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onDelivered,
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: const Text('MARCAR COMO ENTREGUE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0), // Context Transition
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Represents a single delivery stop in the route execution list.
/// Encapsulates the Optimistic UI swipe action and Geofencing highlight logic
/// to maintain Single Responsibility and keep the main list clean.
class DeliveryCard extends StatelessWidget {
  final String clientName;
  final String address;
  final String productsSummary;
  final bool isNear; // Triggered by Geofencing
  final VoidCallback onDelivered;

  const DeliveryCard({
    super.key,
    required this.clientName,
    required this.address,
    required this.productsSummary,
    required this.isNear,
    required this.onDelivered,
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
          // Highlights the card if the user is within the 30m geofence.
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
              const SizedBox(height: 8),
              Text(
                address,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: Color(0xFF333333)),
              ),
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    productsSummary,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0), // Context Transition
    );
  }
}
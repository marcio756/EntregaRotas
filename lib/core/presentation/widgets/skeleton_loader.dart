// Ficheiro: lib/core/presentation/widgets/skeleton_loader.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A reusable Skeleton Screen component to provide optimistic UI feedback
/// during asynchronous loading states (e.g., GPS initialization or API calls).
/// Applying this fulfills the 'Perception of Speed' UX requirement.
/// 
/// @param {double} width - The total width of the skeleton block.
/// @param {double} height - The total height of the skeleton block.
/// @param {double} borderRadius - The rounding of the corners to match the premium design.
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 80.0,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF333333), // Matches the dark theme surface/border base
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
    .animate(onPlay: (controller) => controller.repeat())
    .shimmer(duration: 1200.ms, color: Colors.white24);
  }
}
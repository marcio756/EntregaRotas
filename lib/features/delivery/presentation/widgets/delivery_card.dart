// Ficheiro: lib/features/delivery/presentation/widgets/delivery_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Represents a single delivery stop in the route execution list.
class DeliveryCard extends StatelessWidget {
  final String clientName;
  final String address;
  final List<String> products;
  final bool isNear; 
  final String? imagePath; 
  final bool isDeliveredStatus; // NOVO: Controla o aspeto de histórico do cartão
  final VoidCallback onToggleDelivery; // NOVO: Substitui onDelivered e serve para Entregar/Desfazer
  final Function(int productIndex, bool isIncrement) onQuantityAdjust;

  const DeliveryCard({
    super.key,
    required this.clientName,
    required this.address,
    required this.products,
    required this.isNear,
    this.imagePath,
    this.isDeliveredStatus = false,
    required this.onToggleDelivery,
    required this.onQuantityAdjust,
  });

  void _showQuickImagePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Image.file(File(imagePath!), fit: BoxFit.contain),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Colors.black)]),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Se já foi entregue, desativamos o Swipe para não confundir
    Widget cardContent = Card(
      color: isDeliveredStatus ? theme.cardTheme.color?.withValues(alpha: 0.5) : theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDeliveredStatus 
              ? theme.colorScheme.secondary.withValues(alpha: 0.5) // Borda verde se estiver entregue
              : isNear ? theme.colorScheme.primary : const Color(0xFF333333),
          width: isNear && !isDeliveredStatus ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imagePath != null)
                  GestureDetector(
                    onTap: () => _showQuickImagePreview(context),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(imagePath!)),
                          fit: BoxFit.cover,
                          colorFilter: isDeliveredStatus ? const ColorFilter.mode(Colors.black45, BlendMode.darken) : null,
                        ),
                        border: Border.all(color: const Color(0xFF333333)),
                      ),
                      child: const Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(Icons.zoom_in, size: 18, color: Colors.white54),
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              clientName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: isDeliveredStatus ? Colors.grey : Colors.white,
                                decoration: isDeliveredStatus ? TextDecoration.lineThrough : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isNear && !isDeliveredStatus)
                            const Icon(Icons.location_on, color: Color(0xFF64FFDA))
                                .animate(onPlay: (controller) => controller.repeat())
                                .shimmer(duration: 1500.ms),
                          if (isDeliveredStatus)
                            Icon(Icons.check_circle, color: theme.colorScheme.secondary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: Color(0xFF333333)),
            ),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, idx) {
                final itemStr = products[idx];
                final displayStr = itemStr.split(' | orig: ')[0];
                final lineParts = displayStr.split('x ');
                final qty = lineParts[0];
                final nameAndCat = lineParts.length == 2 ? lineParts[1] : displayStr;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.bakery_dining_outlined, size: 20, color: isDeliveredStatus ? Colors.grey.shade700 : Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          nameAndCat,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isDeliveredStatus ? Colors.grey : Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(Icons.remove_circle_outline, color: isDeliveredStatus ? Colors.transparent : Colors.grey, size: 22),
                            onPressed: isDeliveredStatus ? null : () => onQuantityAdjust(idx, false),
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 30),
                            alignment: Alignment.center,
                            child: Text(
                              qty,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isDeliveredStatus ? Colors.grey : theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(Icons.add_circle_outline, color: isDeliveredStatus ? Colors.transparent : Colors.amber, size: 22),
                            onPressed: isDeliveredStatus ? null : () => onQuantityAdjust(idx, true),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: isDeliveredStatus
                  ? OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                        foregroundColor: theme.colorScheme.error,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onToggleDelivery,
                      icon: const Icon(Icons.undo, size: 20),
                      label: const Text('DESFAZER ENTREGA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    )
                  : OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.secondary.withValues(alpha: 0.5)),
                        foregroundColor: theme.colorScheme.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onToggleDelivery,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text('MARCAR COMO ENTREGUE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
            ),
          ],
        ),
      ),
    );

    if (isDeliveredStatus) {
      return cardContent.animate().fadeIn(duration: 300.ms);
    }

    return Dismissible(
      key: Key(clientName),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        onToggleDelivery();
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
      child: cardContent.animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }
}
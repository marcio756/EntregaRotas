// Ficheiro: lib/features/delivery/presentation/widgets/proximity_delivery_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/database/collections/route_stop_collection.dart';
import '../../../routes/providers/route_stop_provider.dart';

/// Um Dialog que simula um 'Morphing Card Stack' com os pedidos que estão
/// geograficamente próximos. Obriga à interação manual para conclusão.
class ProximityDeliveryDialog extends ConsumerStatefulWidget {
  final List<RouteStop> nearbyStops;
  final String sessionIds;

  const ProximityDeliveryDialog({
    super.key,
    required this.nearbyStops,
    required this.sessionIds,
  });

  @override
  ConsumerState<ProximityDeliveryDialog> createState() => _ProximityDeliveryDialogState();
}

class _ProximityDeliveryDialogState extends ConsumerState<ProximityDeliveryDialog> {
  late List<RouteStop> _stops;

  @override
  void initState() {
    super.initState();
    // Clona a lista para podermos remover itens do topo da pilha à medida que confirmamos
    _stops = List.from(widget.nearbyStops);
  }

  void _confirmDelivery(RouteStop stop) {
    // Altera o estado na base de dados
    ref.read(routeStopsProvider(widget.sessionIds).notifier).toggleDeliveryStatus(stop.id, true);
    _nextCard(stop);
  }

  void _postponeDelivery(RouteStop stop) {
    // Apenas descarta visualmente o cartão sem marcar como entregue
    _nextCard(stop);
  }

  void _nextCard(RouteStop stop) {
    setState(() {
      _stops.remove(stop);
    });
    // Quando a pilha esvaziar, fecha o diálogo e devolve o controlo ao mapa
    if (_stops.isEmpty) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 550,
        width: 360,
        child: Stack(
          alignment: Alignment.center,
          children: _buildCards(theme),
        ),
      ),
    );
  }

  List<Widget> _buildCards(ThemeData theme) {
    List<Widget> cards = [];
    
    // Iteração inversa para garantir que o Index 0 (próximo pedido) fica por cima da pilha
    for (int i = _stops.length - 1; i >= 0; i--) {
      final stop = _stops[i];
      final isTop = i == 0;
      
      cards.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          // Cria o efeito em cascata (cartões mais fundos descem na UI)
          margin: EdgeInsets.only(top: i * 30.0),
          child: AnimatedScale(
            // Reduz o tamanho consoante a profundidade
            scale: 1.0 - (i * 0.05),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _buildCardContent(theme, stop, isTop)
              .animate()
              .fadeIn(duration: 400.ms, delay: (i * 100).ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),
          ),
        )
      );
    }
    return cards;
  }

  Widget _buildCardContent(ThemeData theme, RouteStop stop, bool isTop) {
    return Container(
      height: 480,
      width: 340,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isTop ? theme.colorScheme.primary : const Color(0xFF333333),
          width: isTop ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Secção de Imagem Deslumbrante (Topo)
            Expanded(
              flex: 5,
              child: stop.localImagePath != null
                  ? Image.file(
                      File(stop.localImagePath!),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          const Text('Sem Imagem', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
            ),
            
            // Secção de Conteúdo e Botões (Fundo)
            Expanded(
              flex: 6,
              child: Container(
                color: theme.cardTheme.color,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.orderName,
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 26, fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (stop.notes != null && stop.notes!.isNotEmpty) ...[
                       const SizedBox(height: 4),
                       Text(stop.notes!, style: TextStyle(color: Colors.grey.shade500, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Resumo do Pedido:',
                      style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: stop.productsToDeliver.map((p) {
                            // Limpeza da string para apresentar de forma limpa (remove o "orig:")
                            final cleanStr = p.split(' | orig: ')[0];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                cleanStr, 
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 15)
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Botões de Interação (Apenas visíveis se for o cartão do topo)
                    if (isTop)
                      Row(
                        children: [
                          SizedBox(
                            width: 64,
                            height: 56,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                foregroundColor: Colors.grey,
                                side: const BorderSide(color: Color(0xFF444444)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () => _postponeDelivery(stop),
                              child: const Icon(Icons.close),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: () => _confirmDelivery(stop),
                                icon: const Icon(Icons.check_circle_outline, size: 28),
                                label: const Text('ENTREGUE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.5)),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 200.ms, delay: 100.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/delivery_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Manages the real-time execution of the delivery route.
/// Implements Skeleton loading for perception of speed, Optimistic UI for 
/// instantaneous delivery validation, and a 5-second undo mechanism.
class DeliveryExecutionScreen extends ConsumerStatefulWidget {
  const DeliveryExecutionScreen({super.key});

  @override
  ConsumerState<DeliveryExecutionScreen> createState() => _DeliveryExecutionScreenState();
}

class _DeliveryExecutionScreenState extends ConsumerState<DeliveryExecutionScreen> {
  bool _isLoading = true;
  
  // Temporary local state simulation. In production, this comes from Riverpod Provider & Isar.
  List<Map<String, dynamic>> _deliveries = [];

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  /// Simulates fetching offline data from Isar to demonstrate the Skeleton screen.
  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _deliveries = [
          {"id": "1", "client": "Café Central", "address": "Rua Principal, 45", "products": "20x Carcaça, 5x Pão Forma", "isNear": true},
          {"id": "2", "client": "D. Maria Joana", "address": "Largo da Igreja, 2", "products": "2x Pão de Centeio", "isNear": false},
          {"id": "3", "client": "Minimercado Silva", "address": "Av. da Liberdade, 102", "products": "30x Carcaça", "isNear": false},
        ];
        _isLoading = false;
      });
    }
  }

  /// Handles the optimistic UI delivery action.
  /// Removes the item instantly and provides a 5-second window to undo the action.
  void _handleDeliveryComplete(int index, Map<String, dynamic> delivery) {
    setState(() {
      _deliveries.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${delivery["client"]} entregue com sucesso.'),
        duration: const Duration(seconds: 5), // 5 seconds constraint for Undo
        action: SnackBarAction(
          label: 'DESFAZER',
          textColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            // Reverts the optimistic action if triggered accidentally.
            setState(() {
              _deliveries.insert(index, delivery);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rota Atual', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              // Future navigation to Map View with Continuity Transition
            },
          )
        ],
      ),
      body: _isLoading 
          ? _buildSkeletonList() 
          : _buildDeliveryList(),
    );
  }

  /// Renders a skeleton screen to improve perceived performance during load.
  Widget _buildSkeletonList() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return const Card(
          child: SizedBox(height: 140, width: double.infinity),
        ).animate(onPlay: (controller) => controller.repeat())
         .shimmer(duration: 1200.ms, color: Colors.white10);
      },
    );
  }

  /// Renders the actual list of deliveries with Context Transitions.
  Widget _buildDeliveryList() {
    if (_deliveries.isEmpty) {
      return const Center(
        child: Text('Todas as entregas concluídas!'),
      );
    }

    return ListView.builder(
      itemCount: _deliveries.length,
      itemBuilder: (context, index) {
        final delivery = _deliveries[index];
        return DeliveryCard(
          clientName: delivery["client"],
          address: delivery["address"],
          productsSummary: delivery["products"],
          isNear: delivery["isNear"],
          onDelivered: () => _handleDeliveryComplete(index, delivery),
        );
      },
    );
  }
}
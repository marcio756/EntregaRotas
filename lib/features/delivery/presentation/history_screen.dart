// Ficheiro: lib/features/delivery/presentation/history_screen.dart
import 'package:flutter/material.dart';
import '../../../core/services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<Map<String, dynamic>> _historyLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final logs = await _historyService.fetchAllLogs();
    if (mounted) {
      setState(() {
        _historyLogs = logs;
        _isLoading = false;
      });
    }
  }

  void _viewDayDetails(Map<String, dynamic> log) {
    final theme = Theme.of(context);
    final delivered = Map<String, int>.from(log['delivered'] as Map);
    final notDelivered = Map<String, int>.from(log['notDelivered'] as Map);
    final extra = Map<String, int>.from(log['extra'] as Map);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(log['date'] as String, style: theme.textTheme.titleLarge?.copyWith(fontSize: 26)),
                      Chip(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        label: Text(log['routeName'] as String, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Color(0xFF2C2C2C)),
                  ),
                  
                  _buildSectionTitle('Produtos Entregues', Colors.green),
                  _buildStockMap(delivered, theme, Colors.green, 'unidades'),
                  
                  const SizedBox(height: 20),
                  _buildSectionTitle('Faltas / Não Entregues', theme.colorScheme.error),
                  _buildStockMap(notDelivered, theme, theme.colorScheme.error, 'unidades'),
                  
                  const SizedBox(height: 20),
                  _buildSectionTitle('Entregues a Mais', Colors.lightBlue),
                  _buildStockMap(extra, theme, Colors.lightBlue, 'excedentes'),
                  
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildStockMap(Map<String, int> stock, ThemeData theme, Color color, String suffix) {
    if (stock.isEmpty) {
      return Text('Sem registos nesta categoria.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey));
    }
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2C)),
      ),
      child: Column(
        children: stock.entries.map((e) => ListTile(
          dense: true,
          title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: Text('${e.value} $suffix', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Distribuição')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyLogs.isEmpty
              ? const Center(child: Text('Nenhum dia de trabalho arquivado.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _historyLogs.length,
                  itemBuilder: (context, idx) {
                    final log = _historyLogs[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.calendar_today_outlined, color: theme.colorScheme.primary, size: 20),
                        ),
                        title: Text(log['date'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text(log['routeName'] as String, style: const TextStyle(color: Colors.grey)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => _viewDayDetails(log),
                      ),
                    );
                  },
                ),
    );
  }
}
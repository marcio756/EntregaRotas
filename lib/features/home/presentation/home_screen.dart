// Ficheiro: lib/features/home/presentation/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/providers/route_provider.dart';
import '../../routes/providers/route_group_provider.dart';
import '../../delivery/presentation/delivery_execution_screen.dart';
import '../../routes/presentation/route_load_sheet_screen.dart'; 
import '../../../core/services/backup_service.dart'; 
import '../../../core/database/collections/route_collection.dart'; // Importação do modelo adicionada

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            tooltip: 'Gestão de Backups',
            onPressed: () => _showBackupOptions(context),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
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
            
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => _showRouteSelection(context, ref),
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

  void _showBackupOptions(BuildContext context) {
    final backupService = BackupService();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Segurança e Backups', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('Guarda ou recupera todo o teu trabalho.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                ListTile(
                  leading: CircleAvatar(backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2), child: Icon(Icons.upload_file, color: theme.colorScheme.primary)),
                  title: const Text('Exportar Backup', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Criar um ficheiro .zip (Rotas, Fotos e Histórico).'),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext); 
                    _showLoading(context, 'A criar backup íntegro...');
                    
                    final success = await backupService.exportBackup();
                    
                    if (context.mounted) {
                      Navigator.pop(context); 
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Backup guardado com sucesso!' : 'Operação cancelada ou falhou.'),
                          backgroundColor: success ? Colors.green : theme.colorScheme.error,
                        ),
                      );
                    }
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Color(0xFF333333)),
                ),
                ListTile(
                  leading: CircleAvatar(backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.2), child: Icon(Icons.download_rounded, color: theme.colorScheme.secondary)),
                  title: const Text('Importar Backup', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Recuperar dados a partir de um ficheiro .zip.'),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Atenção: Substituir Dados?'),
                        content: const Text('Ao importar, todos os dados atuais da aplicação serão apagados e substituídos pelos do ficheiro.\n\nQueres mesmo continuar?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error, foregroundColor: Colors.white),
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              _showLoading(context, 'A extrair e restaurar ficheiros...');
                              
                              final success = await backupService.importBackup();
                              
                              if (context.mounted) {
                                Navigator.pop(context);
                                
                                if (success) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Restauro Concluído!'),
                                      content: const Text('Os teus dados foram recuperados.\nA aplicação precisa de ser reiniciada agora para carregar a nova base de dados.\n\nPor favor, fecha a app e volta a abrir.'),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            // Correção do linter: chavetas nos ifs
                                            if (Platform.isAndroid) {
                                              SystemNavigator.pop();
                                            } else {
                                              exit(0);
                                            }
                                          }, 
                                          child: const Text('FECHAR APP')
                                        )
                                      ],
                                    )
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: const Text('Importação cancelada ou falhou.'), backgroundColor: theme.colorScheme.error)
                                  );
                                }
                              }
                            },
                            child: const Text('SIM, RESTAURAR'),
                          ),
                        ],
                      )
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLoading(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showRouteSelection(BuildContext context, WidgetRef ref) {
    final routes = ref.read(routeListProvider);
    final groups = ref.read(routeGroupListProvider);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        if (routes.isEmpty && groups.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('Nenhuma rota ou grupo criado. Vá ao menu "Rotas".'),
          );
        }

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SafeArea(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24.0),
                children: [
                  Text('Qual o plano de trabalho?', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  
                  if (groups.isNotEmpty) ...[
                    const Text('Grupos', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...groups.map((group) => Card(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.amber, width: 1)),
                      child: ListTile(
                        leading: const Icon(Icons.layers, color: Colors.amber),
                        title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text('Iniciar ${group.routes.length} rotas juntas', style: const TextStyle(color: Colors.grey)),
                        trailing: _buildActions(context, group.routes.toList(), group.name, group.routes.map((r)=>r.id).join(',')),
                        onTap: () => _startSession(context, group.routes.toList(), group.name, group.routes.map((r)=>r.id).join(',')),
                      ),
                    )),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF333333))),
                  ],

                  if (routes.isNotEmpty) ...[
                    const Text('Rotas Simples', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...routes.map((route) => Card(
                      child: ListTile(
                        title: Text(route.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: const Text('Iniciar rota normal', style: TextStyle(color: Colors.grey)),
                        trailing: _buildActions(context, [route], route.name, route.id.toString()),
                        onTap: () => _startSession(context, [route], route.name, route.id.toString()),
                      ),
                    )),
                  ]
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildActions(BuildContext context, List<DeliveryRoute> activeRoutes, String name, String ids) {
    final theme = Theme.of(context);
    return IconButton(
      tooltip: 'Validar Carga Total',
      style: IconButton.styleFrom(backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1)),
      icon: Icon(Icons.inventory_2_outlined, color: theme.colorScheme.primary),
      onPressed: () {
        Navigator.pop(context); 
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RouteLoadSheetScreen(
              activeRoutes: activeRoutes,
              sessionName: name,
              sessionIds: ids,
            ),
          ),
        );
      },
    );
  }

  void _startSession(BuildContext context, List<DeliveryRoute> activeRoutes, String name, String ids) {
    Navigator.pop(context); 
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeliveryExecutionScreen(
          activeRoutes: activeRoutes,
          sessionName: name,
          sessionIds: ids,
        ),
      ),
    );
  }
}
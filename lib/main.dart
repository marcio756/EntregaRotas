import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/presentation/main_shell_screen.dart';
import 'core/database/isar_service.dart';

// Variável global para acesso rápido à instância da base de dados no Riverpod
late IsarService isarService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialização forçada da base de dados local antes de desenhar a UI.
  // Garante que a app offline-first tem os dados prontos imediatamente.
  isarService = IsarService();
  await isarService.db;

  runApp(
    const ProviderScope(
      child: PaoRotaApp(),
    ),
  );
}

/// Root widget of the application.
/// Integrates the premium dark theme and routes to the Main Shell navigation.
class PaoRotaApp extends StatelessWidget {
  const PaoRotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rota do Pão',
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Enforcing native Dark Mode
      debugShowCheckedModeBanner: false,
      home: const MainShellScreen(), // Agora arranca para o menu principal
    );
  }
}
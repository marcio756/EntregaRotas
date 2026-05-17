import 'package:flutter/material.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/products/presentation/products_list_screen.dart';
import '../../features/routes/presentation/routes_management_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RoutesManagementScreen(),
    const ProductsListScreen(), // Substituiu a posição dos clientes
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.route_outlined), label: 'Rotas'),
          NavigationDestination(icon: Icon(Icons.bakery_dining_outlined), label: 'Produtos'),
        ],
      ),
    );
  }
}
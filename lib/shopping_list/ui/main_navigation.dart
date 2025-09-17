import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'shopping_lists_page.dart';
import 'purchases_page.dart';
import 'dashboard_page.dart';
import 'stores_page.dart';
import 'purchase_detail_page.dart';
import '../model/store_purchase_models.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ShoppingListsPage(),
    const PurchasesPage(), 
    const DashboardPage(),
    const StoresPage(),
  ];

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.list_outlined),
      selectedIcon: Icon(Icons.list),
      label: 'Mis Listas',
    ),
    const NavigationDestination(
      icon: Icon(Icons.shopping_cart_outlined),
      selectedIcon: Icon(Icons.shopping_cart),
      label: 'Compras',
    ),
    const NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: 'Dashboard',
    ),
    const NavigationDestination(
      icon: Icon(Icons.store_outlined),
      selectedIcon: Icon(Icons.store),
      label: 'Tiendas',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: _destinations,
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Mis Listas';
      case 1:
        return 'Compras';
      case 2:
        return 'Dashboard';
      case 3:
        return 'Tiendas';
      default:
        return 'Lista Smart';
    }
  }

  // Método helper para navegación desde otras partes de la app
  void navigateToPurchaseDetail(Purchase purchase) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PurchaseDetailPage(purchase: purchase),
      ),
    );
  }

  // Método helper para navegar a una pestaña específica
  void navigateToTab(int tabIndex) {
    if (tabIndex >= 0 && tabIndex < _destinations.length) {
      setState(() => _selectedIndex = tabIndex);
    }
  }
}
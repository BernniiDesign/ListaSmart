import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'shopping_lists_page.dart';
import 'purchases_page.dart';
import 'dashboard_page.dart';
import 'stores_page.dart';
import 'purchase_detail_page.dart';
import 'dialogs/list_dialog.dart';
import 'dialogs/create_purchase_dialog.dart';
import 'dialogs/store_dialog.dart';
import '../state/shopping_providers.dart';
import '../model/store_purchase_models.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _pageAnimationController;
  late AnimationController _appBarAnimationController;
  late Animation<double> _pageAnimation;
  late Animation<Offset> _appBarSlideAnimation;
  late Animation<double> _appBarFadeAnimation;

  final List<Widget> _pages = [
    const ShoppingListsPage(),
    const PurchasesPage(),
    const DashboardPage(),
    const StoresPage(),
  ];

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.list_outlined,
      selectedIcon: Icons.list,
      label: 'Mis Listas',
      gradient: const LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      ),
    ),
    NavItem(
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      label: 'Compras',
      gradient: const LinearGradient(
        colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
      ),
    ),
    NavItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'Dashboard',
      gradient: const LinearGradient(
        colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      ),
    ),
    NavItem(
      icon: Icons.store_outlined,
      selectedIcon: Icons.store,
      label: 'Tiendas',
      gradient: const LinearGradient(
        colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _appBarSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _appBarAnimationController,
      curve: Curves.elasticOut,
    ));

    _appBarFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _appBarAnimationController,
      curve: Curves.easeOut,
    ));

    _pageAnimationController.forward();
    _appBarAnimationController.forward();
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _appBarAnimationController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    // Reiniciar animaciones para transición suave
    _pageAnimationController.reset();
    _appBarAnimationController.reset();
    _pageAnimationController.forward();
    _appBarAnimationController.forward();

    // Haptic feedback
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AnimatedBuilder(
          animation: _appBarAnimationController,
          builder: (context, child) {
            return SlideTransition(
              position: _appBarSlideAnimation,
              child: FadeTransition(
                opacity: _appBarFadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _navItems[_selectedIndex].gradient,
                    boxShadow: [
                      BoxShadow(
                        color: _navItems[_selectedIndex]
                            .gradient
                            .colors
                            .first
                            .withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    title: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _getTitle(),
                        key: ValueKey(_selectedIndex),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          tooltip: 'Cerrar sesión',
                          onPressed: () async {
                            await _showLogoutDialog();
                          },
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      body: AnimatedBuilder(
        animation: _pageAnimationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _pageAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _pageAnimationController,
                curve: Curves.easeOutCubic,
              )),
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          );
        },
      ),
      // Permitir que cada página tenga su propio FloatingActionButton
      floatingActionButton: _getFloatingActionButton(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: AnimatedNavBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            items: _navItems,
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    return _navItems[_selectedIndex].label;
  }

  Widget? _getFloatingActionButton() {
    // Retornar el FAB apropiado según la pestaña seleccionada
    switch (_selectedIndex) {
      case 0: // Mis Listas
        return FloatingActionButton.extended(
          onPressed: () => _createNewShoppingList(),
          icon: const Icon(Icons.add),
          label: const Text('Nueva Lista'),
          backgroundColor: _navItems[_selectedIndex].gradient.colors.first,
        );
      case 1: // Compras
        return FloatingActionButton.extended(
          onPressed: () => _createNewPurchase(),
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Nueva Compra'),
          backgroundColor: _navItems[_selectedIndex].gradient.colors.first,
        );
      case 3: // Tiendas
        return FloatingActionButton.extended(
          onPressed: () => _createNewStore(),
          icon: const Icon(Icons.add_business),
          label: const Text('Nueva Tienda'),
          backgroundColor: _navItems[_selectedIndex].gradient.colors.first,
        );
      default:
        return null; // Dashboard no necesita FAB
    }
  }

  // Métodos para crear nuevos elementos usando la funcionalidad existente
  Future<void> _createNewShoppingList() async {
    // Importar el diálogo existente
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ListDialog(), // Usamos el diálogo existente
    );

    if (result != null) {
      await ref.read(shoppingListsProvider.notifier).createList(
        result['name'] as String,
        description: result['description'] as String?,
      );
    }
  }

  Future<void> _createNewPurchase() async {
    // Usar el diálogo existente de crear compra
    final result = await showDialog<Purchase>(
      context: context,
      builder: (context) => const CreatePurchaseDialog(),
    );

    if (result != null && context.mounted) {
      // Navegar al detalle de la compra recién creada
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PurchaseDetailPage(purchase: result),
        ),
      );
    }
  }

  Future<void> _createNewStore() async {
    // Usar el diálogo existente de crear tienda
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const StoreDialog(),
    );

    if (result != null) {
      await ref.read(storesProvider.notifier).createStore(
        result['name'] as String,
        location: result['location'] as String?,
      );
    }
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cerrar sesión'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Supabase.instance.client.auth.signOut();
              },
            ),
          ],
        );
      },
    );
  }

  void navigateToPurchaseDetail(Purchase purchase) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PurchaseDetailPage(purchase: purchase),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void navigateToTab(int tabIndex) {
    if (tabIndex >= 0 && tabIndex < _navItems.length) {
      _onDestinationSelected(tabIndex);
    }
  }

  // Método helper para acceder a funciones específicas desde las páginas
  void createNewPurchaseFromPage() {
    _createNewPurchase();
  }

  void createNewShoppingListFromPage() {
    _createNewShoppingList();
  }

  void createNewStoreFromPage() {
    _createNewStore();
  }
}

class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final LinearGradient gradient;

  const NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.gradient,
  });
}

class AnimatedNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<NavItem> items;

  const AnimatedNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
  });

  @override
  State<AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    _animations = _controllers
        .map((controller) => Tween<double>(begin: 1.0, end: 0.8)
            .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)))
        .toList();

    // Animar el ítem seleccionado inicialmente
    _controllers[widget.selectedIndex].forward();
  }

  @override
  void didUpdateWidget(AnimatedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _controllers[oldWidget.selectedIndex].reverse();
      _controllers[widget.selectedIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final isSelected = index == widget.selectedIndex;

          return Expanded(
            child: AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: _animations[index].value,
                  child: GestureDetector(
                    onTap: () => widget.onDestinationSelected(index),
                    onTapDown: (_) => _controllers[index].forward(),
                    onTapUp: (_) => _controllers[index].reverse(),
                    onTapCancel: () => _controllers[index].reverse(),
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: isSelected ? item.gradient : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: item.gradient.colors.first
                                      .withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              key: ValueKey('${index}_$isSelected'),
                              size: 24,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                            child: Text(
                              item.label,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

// Agregamos HapticFeedback si no está disponible
class HapticFeedback {
  static void selectionClick() {
    // Implementación de feedback háptico si está disponible
    // En Flutter, puedes usar el paquete flutter/services.dart
    // SystemSound.play(SystemSoundType.click);
  }
}
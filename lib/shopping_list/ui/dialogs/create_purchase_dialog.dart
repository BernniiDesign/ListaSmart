import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/shopping_providers.dart';
import '../../model/shopping_list.dart';
import '../../model/store_purchase_models.dart';

class CreatePurchaseDialog extends ConsumerStatefulWidget {
  final ShoppingList? preselectedList;

  const CreatePurchaseDialog({
    super.key,
    this.preselectedList,
  });

  @override
  ConsumerState<CreatePurchaseDialog> createState() => _CreatePurchaseDialogState();
}

class _CreatePurchaseDialogState extends ConsumerState<CreatePurchaseDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _notesController = TextEditingController();
  
  ShoppingList? _selectedList;
  Store? _selectedStore;
  bool _isCreatingStore = false;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedList = widget.preselectedList;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _storeNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.surface,
                      colorScheme.surface.withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header moderno
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.secondaryContainer,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart,
                              color: colorScheme.onPrimary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nueva Compra',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                Text(
                                  'Registra una nueva compra',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close_rounded,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Contenido del formulario
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildListSelector(),
                            const SizedBox(height: 20),
                            _buildStoreSelector(),
                            const SizedBox(height: 20),
                            _buildNotesField(),
                            const SizedBox(height: 32),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListSelector() {
    final listsAsync = ref.watch(shoppingListsProvider);
    
    return listsAsync.when(
      loading: () => const _LoadingField(),
      error: (error, stack) => _ErrorField(error: error.toString()),
      data: (lists) => _AnimatedCard(
        child: DropdownButtonFormField<ShoppingList>(
          value: _selectedList,
          decoration: InputDecoration(
            labelText: 'Lista base (opcional)',
            hintText: 'Selecciona una lista...',
            prefixIcon: Icon(
              Icons.list_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          items: lists.map((list) => DropdownMenuItem(
            value: list,
            child: Row(
              children: [
                Icon(
                  Icons.shopping_basket_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(list.name)),
              ],
            ),
          )).toList(),
          onChanged: (value) => setState(() => _selectedList = value),
        ),
      ),
    );
  }

  Widget _buildStoreSelector() {
    final storesAsync = ref.watch(storesProvider);
    
    return storesAsync.when(
      loading: () => const _LoadingField(),
      error: (error, stack) => _ErrorField(error: error.toString()),
      data: (stores) => _AnimatedCard(
        child: Column(
          children: [
            if (!_isCreatingStore) ...[
              DropdownButtonFormField<Store>(
                value: _selectedStore,
                decoration: InputDecoration(
                  labelText: 'Tienda',
                  hintText: 'Selecciona una tienda...',
                  prefixIcon: Icon(
                    Icons.store_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.add_business_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () => setState(() => _isCreatingStore = true),
                    tooltip: 'Crear nueva tienda',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                items: stores.map((store) => DropdownMenuItem(
                  value: store,
                  child: Row(
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(store.name)),
                      if (store.location != null)
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                    ],
                  ),
                )).toList(),
                onChanged: (value) => setState(() => _selectedStore = value),
                validator: (value) {
                  if (value == null && _storeNameController.text.trim().isEmpty) {
                    return 'Selecciona una tienda o crea una nueva';
                  }
                  return null;
                },
              ),
            ] else ...[
              TextFormField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la nueva tienda',
                  hintText: 'Ej: Walmart Centro...',
                  prefixIcon: Icon(
                    Icons.add_business_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () {
                      setState(() {
                        _isCreatingStore = false;
                        _storeNameController.clear();
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                ),
                validator: (value) {
                  if (_isCreatingStore && (value == null || value.trim().isEmpty)) {
                    return 'Ingresa el nombre de la tienda';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return _AnimatedCard(
      child: TextFormField(
        controller: _notesController,
        decoration: InputDecoration(
          labelText: 'Notas (opcional)',
          hintText: 'Compra de emergencia, oferta especial...',
          prefixIcon: Icon(
            Icons.note_add_rounded,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
        ),
        maxLines: 3,
        minLines: 1,
      ),
    );
  }

  Widget _buildActionButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: _isLoading ? null : _createPurchase,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_shopping_cart, size: 20),
                      const SizedBox(width: 8),
                      const Text('Crear Compra'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _createPurchase() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      String storeName;
      String? storeId;

      if (_isCreatingStore) {
        storeName = _storeNameController.text.trim();
        await ref.read(storesProvider.notifier).createStore(storeName);
        
        final updatedStores = ref.read(storesProvider).value ?? [];
        final newStore = updatedStores.cast<Store?>().lastWhere(
          (store) => store?.name == storeName,
          orElse: () => null,
        );
        
        storeId = newStore?.id;
      } else {
        storeName = _selectedStore?.name ?? 'Tienda desconocida';
        storeId = _selectedStore?.id;
      }

      final purchase = await ref.read(purchasesProvider.notifier).createPurchase(
        listId: _selectedList?.id,
        storeId: storeId,
        storeName: storeName,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (purchase != null && mounted) {
        Navigator.of(context).pop(purchase);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear compra: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _AnimatedCard extends StatelessWidget {
  final Widget child;

  const _AnimatedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LoadingField extends StatelessWidget {
  const _LoadingField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _ErrorField extends StatelessWidget {
  final String error;

  const _ErrorField({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Error: $error',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
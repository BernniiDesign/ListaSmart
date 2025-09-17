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

class _CreatePurchaseDialogState extends ConsumerState<CreatePurchaseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _notesController = TextEditingController();
  
  ShoppingList? _selectedList;
  Store? _selectedStore;
  bool _isCreatingStore = false;

  @override
  void initState() {
    super.initState();
    _selectedList = widget.preselectedList;
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(shoppingListsProvider);
    final storesAsync = ref.watch(storesProvider);

    return AlertDialog(
      title: const Text('Nueva Compra'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Seleccionar lista
            listsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
              data: (lists) => DropdownButtonFormField<ShoppingList>(
                value: _selectedList,
                decoration: const InputDecoration(
                  labelText: 'Lista base (opcional)',
                  hintText: 'Selecciona una lista...',
                ),
                items: lists.map((list) => DropdownMenuItem(
                  value: list,
                  child: Text(list.name),
                )).toList(),
                onChanged: (value) => setState(() => _selectedList = value),
              ),
            ),
            const SizedBox(height: 16),

            // Seleccionar o crear tienda
            storesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
              data: (stores) => Column(
                children: [
                  if (!_isCreatingStore) ...[
                    DropdownButtonFormField<Store>(
                      value: _selectedStore,
                      decoration: InputDecoration(
                        labelText: 'Tienda',
                        hintText: 'Selecciona una tienda...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => _isCreatingStore = true),
                          tooltip: 'Crear nueva tienda',
                        ),
                      ),
                      items: stores.map((store) => DropdownMenuItem(
                        value: store,
                        child: Text(store.name),
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
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _isCreatingStore = false;
                              _storeNameController.clear();
                            });
                          },
                        ),
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
            const SizedBox(height: 16),

            // Notas opcionales
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Compra de emergencia, oferta especial...',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _createPurchase,
          child: const Text('Crear Compra'),
        ),
      ],
    );
  }

  Future<void> _createPurchase() async {
  if (!(_formKey.currentState?.validate() ?? false)) return;

  try {
    String storeName;
    String? storeId;

    if (_isCreatingStore) {
      // Crear nueva tienda
      storeName = _storeNameController.text.trim();
      
      // Llamar al método createStore (que retorna void)
      await ref.read(storesProvider.notifier).createStore(storeName);
      
      // Obtener la lista actualizada de tiendas para encontrar la recién creada
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

    // Crear la compra
    final purchase = await ref.read(purchasesProvider.notifier).createPurchase(
      listId: _selectedList?.id,
      storeId: storeId,
      storeName: storeName,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (purchase != null && context.mounted) {
      Navigator.of(context).pop(purchase);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear compra: $e')),
      );
    }
  }
}
}
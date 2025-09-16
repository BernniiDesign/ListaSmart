import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/shopping_providers.dart';
import '../model/shopping_list.dart';
import '../model/shopping_list.dart' as models;
import 'dialogs/list_item_dialog.dart';

class ShoppingListDetailPage extends ConsumerWidget {
  final ShoppingList list;

  const ShoppingListDetailPage({super.key, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(listItemsProvider(list.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'use_for_purchase',
                child: ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text('Usar para compra'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Limpiar lista'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(listItemsProvider(list.id)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? _EmptyState(onAddItem: () => _showAddItemDialog(context, ref))
            : _ItemsListView(items: items, listId: list.id),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Item'),
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ListItemDialog(),
    );

    if (result != null) {
      await ref.read(listItemsProvider(list.id).notifier).addItem(
        result['name'] as String,
        result['qty'] as int,
        category: result['category'] as String?,
      );
    }
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'use_for_purchase':
        // Navegar a crear compra con esta lista
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Función próximamente')),
        );
        break;
      case 'clear_all':
        // Confirmar y limpiar todos los items
        _showClearAllDialog(context, ref);
        break;
    }
  }

  Future<void> _showClearAllDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Lista'),
        content: const Text('¿Estás seguro de que quieres eliminar todos los items de esta lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implementar limpiar todos los items
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Función próximamente')),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddItem;
  
  const _EmptyState({required this.onAddItem});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 120,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            'Lista vacía',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos a tu lista\npara empezar a organizarte',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onAddItem,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Producto'),
          ),
        ],
      ),
    );
  }
}

class _ItemsListView extends ConsumerWidget {
  final List<models.ShoppingListItem> items;
  final String listId;
  
  const _ItemsListView({required this.items, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(listItemsProvider(listId));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        itemBuilder: (context, index) => _ItemCard(
          item: items[index],
          listId: listId,
        ),
      ),
    );
  }
}

class _ItemCard extends ConsumerWidget {
  final models.ShoppingListItem item;
  final String listId;
  
  const _ItemCard({required this.item, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          child: Text('${item.qty}'),
        ),
        title: Text(item.name),
        subtitle: item.category != null 
            ? Text(item.category!)
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, ref, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'edit':
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => ListItemDialog(
            initialName: item.name,
            initialQty: item.qty,
            initialCategory: item.category,
          ),
        );
        if (result != null) {
          await ref.read(listItemsProvider(listId).notifier).updateItem(
            item.id,
            result['name'] as String,
            result['qty'] as int,
            category: result['category'] as String?,
          );
        }
        break;
        
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar Producto'),
            content: Text('¿Estás seguro de que quieres eliminar "${item.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
        
        if (confirmed == true) {
          await ref.read(listItemsProvider(listId).notifier).deleteItem(item.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Producto "${item.name}" eliminado')),
            );
          }
        }
        break;
    }
  }
}
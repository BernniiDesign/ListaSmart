import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/shopping_providers.dart';
import '../model/shopping_list.dart';
import 'shopping_list_detail_page.dart';
import 'dialogs/list_dialog.dart';

class ShoppingListsPage extends ConsumerWidget {
  const ShoppingListsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(shoppingListsProvider);

    return Scaffold(
      body: listsAsync.when(
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
                onPressed: () => ref.invalidate(shoppingListsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (lists) => lists.isEmpty
            ? _EmptyState(onAddList: () => _showCreateListDialog(context, ref))
            : _ListsView(lists: lists),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateListDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Lista'),
      ),
    );
  }

  Future<void> _showCreateListDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ListDialog(),
    );

    if (result != null) {
      await ref.read(shoppingListsProvider.notifier).createList(
        result['name'] as String,
        description: result['description'] as String?,
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddList;
  
  const _EmptyState({required this.onAddList});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.list_alt_outlined,
            size: 120,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            'No tienes listas aún',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera lista de compras\npara organizar tus productos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onAddList,
            icon: const Icon(Icons.add),
            label: const Text('Crear Lista'),
          ),
        ],
      ),
    );
  }
}

class _ListsView extends ConsumerWidget {
  final List<ShoppingList> lists;
  
  const _ListsView({required this.lists});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(shoppingListsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: lists.length,
        itemBuilder: (context, index) => _ListCard(list: lists[index]),
      ),
    );
  }
}

class _ListCard extends ConsumerWidget {
  final ShoppingList list;
  
  const _ListCard({required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: const Icon(Icons.list),
        ),
        title: Text(list.name),
        subtitle: list.description != null 
            ? Text(list.description!)
            : Text('Creada el ${_formatDate(list.createdAt)}'),
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
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Duplicar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'use_for_purchase',
              child: ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('Usar para compra'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
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
        onTap: () => _navigateToListDetail(context),
      ),
    );
  }

  void _navigateToListDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShoppingListDetailPage(list: list),
      ),
    );
  }

  Future<void> _handleMenuAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'edit':
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => ListDialog(
            initialName: list.name,
            initialDescription: list.description,
          ),
        );
        if (result != null) {
          await ref.read(shoppingListsProvider.notifier).updateList(
            list.id,
            result['name'] as String,
            description: result['description'] as String?,
          );
        }
        break;
        
      case 'duplicate':
        await ref.read(shoppingListsProvider.notifier).createList(
          '${list.name} (Copia)',
          description: list.description,
        );
        break;
        
      case 'use_for_purchase':
        // Navegar a crear compra con esta lista
        // TODO: Implementar navegación a crear compra
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Función próximamente')),
        );
        break;
        
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar Lista'),
            content: Text('¿Estás seguro de que quieres eliminar "${list.name}"?'),
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
          await ref.read(shoppingListsProvider.notifier).deleteList(list.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lista "${list.name}" eliminada')),
            );
          }
        }
        break;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
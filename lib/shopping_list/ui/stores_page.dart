import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/shopping_providers.dart';
import '../model/store_purchase_models.dart';
import 'dialogs/store_dialog.dart';

class StoresPage extends ConsumerWidget {
  const StoresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(storesProvider);

    return Scaffold(
      body: storesAsync.when(
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
                onPressed: () => ref.invalidate(storesProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (stores) => stores.isEmpty
            ? _EmptyState(onAddStore: () => _showCreateStoreDialog(context, ref))
            : _StoresListView(stores: stores),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateStoreDialog(context, ref),
        icon: const Icon(Icons.add_business),
        label: const Text('Nueva Tienda'),
      ),
    );
  }

  Future<void> _showCreateStoreDialog(BuildContext context, WidgetRef ref) async {
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
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddStore;
  
  const _EmptyState({required this.onAddStore});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.store_outlined,
            size: 120,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            'No tienes tiendas registradas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Registra tus tiendas favoritas\npara organizar mejor tus compras',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onAddStore,
            icon: const Icon(Icons.add_business),
            label: const Text('Agregar Tienda'),
          ),
        ],
      ),
    );
  }
}

class _StoresListView extends ConsumerWidget {
  final List<Store> stores;
  
  const _StoresListView({required this.stores});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(storesProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: stores.length,
        itemBuilder: (context, index) => _StoreCard(store: stores[index]),
      ),
    );
  }
}

class _StoreCard extends ConsumerWidget {
  final Store store;
  
  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          child: const Icon(Icons.store),
        ),
        title: Text(store.name),
        subtitle: store.location != null 
            ? Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      store.location!,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Text('Agregada el ${_formatDate(store.createdAt)}'),
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
              value: 'view_purchases',
              child: ListTile(
                leading: Icon(Icons.receipt_long),
                title: Text('Ver compras'),
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
        onTap: () => _navigateToStoreDetail(context),
      ),
    );
  }

  void _navigateToStoreDetail(BuildContext context) {
    // Navegar a detalle de tienda con sus compras y estadísticas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función próximamente - Ver detalle de tienda')),
    );
  }

  Future<void> _handleMenuAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'edit':
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => StoreDialog(
            initialName: store.name,
            initialLocation: store.location,
          ),
        );
        if (result != null) {
          await ref.read(storesProvider.notifier).updateStore(
            store.id,
            result['name'] as String,
            location: result['location'] as String?,
          );
        }
        break;
        
      case 'view_purchases':
        // Ver compras en esta tienda
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Función próximamente - Ver compras de esta tienda')),
        );
        break;
        
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar Tienda'),
            content: Text('¿Estás seguro de que quieres eliminar "${store.name}"?'),
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
          await ref.read(storesProvider.notifier).deleteStore(store.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tienda "${store.name}" eliminada')),
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
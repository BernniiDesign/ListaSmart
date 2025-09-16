import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_init.dart';
import '../shopping_list/state/notifiers.dart';
import '../shopping_list/ui/item_dialog.dart';
import '../shopping_list/model/grocery_item.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi lista de compras'),
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
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => list.isEmpty
            ? const _Empty()
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: list.length,
                itemBuilder: (_, i) => _ItemTile(item: list[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (_) => const ItemDialog(),
          );
          if (result != null) {
            ref.read(itemsProvider.notifier).add(
                  result['name'] as String,
                  result['qty'] as int,
                );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_checkout, size: 72, color: cs.primary),
          const SizedBox(height: 16),
          const Text('Tu lista está vacía. ¡Agrega tu primer ítem!'),
        ],
      ),
    );
  }
}

class _ItemTile extends ConsumerWidget {
  final GroceryItem item;
  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: item.done,
          onChanged: (_) => ref.read(itemsProvider.notifier).toggle(item),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('Cantidad: ${item.qty}'),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            switch (v) {
              case 'edit':
                final res = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (_) => ItemDialog(initialName: item.name, initialQty: item.qty),
                );
                if (res != null) {
                  ref.read(itemsProvider.notifier).update(
                        item.copyWith(name: res['name'] as String, qty: res['qty'] as int),
                      );
                }
                break;
              case 'delete':
                ref.read(itemsProvider.notifier).remove(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Eliminado'),
                    action: SnackBarAction(
                      label: 'Deshacer',
                      onPressed: () {
                        // No-op simple demo; in real app keep a trash or redo action
                      },
                    ),
                  ),
                );
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }
}

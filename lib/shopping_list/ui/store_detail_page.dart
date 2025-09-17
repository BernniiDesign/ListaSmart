import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listasmart/shopping_list/ui/dialogs/store_dialog.dart';
import '../state/shopping_providers.dart';
import '../model/store_purchase_models.dart';
import 'purchase_detail_page.dart';

class StoreDetailPage extends ConsumerWidget {
  final Store store;

  const StoreDetailPage({super.key, required this.store});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filtrar compras por tienda
    final purchasesAsync = ref.watch(purchasesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(store.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editStore(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Información de la tienda
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Información de la Tienda',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (store.location != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(store.location!)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text('Agregada el ${_formatDate(store.createdAt)}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Lista de compras en esta tienda
          Expanded(
            child: purchasesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (allPurchases) {
                final storePurchases = allPurchases
                    .where((p) => p.storeId == store.id)
                    .toList()
                  ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
                
                if (storePurchases.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No hay compras registradas en esta tienda'),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: storePurchases.length,
                  itemBuilder: (context, index) => _PurchaseCard(
                    purchase: storePurchases[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editStore(BuildContext context, WidgetRef ref) async {
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
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _PurchaseCard extends StatelessWidget {
  final Purchase purchase;
  
  const _PurchaseCard({required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.receipt),
        ),
        title: Text(_formatDate(purchase.purchaseDate)),
        subtitle: purchase.notes != null ? Text(purchase.notes!) : null,
        trailing: Text(
          '${purchase.currency} ${purchase.totalAmount.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PurchaseDetailPage(purchase: purchase),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
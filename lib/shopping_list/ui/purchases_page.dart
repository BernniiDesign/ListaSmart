import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/shopping_providers.dart';
import '../model/store_purchase_models.dart';

class PurchasesPage extends ConsumerWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchasesProvider);

    return Scaffold(
      body: purchasesAsync.when(
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
                onPressed: () => ref.invalidate(purchasesProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (purchases) => purchases.isEmpty
            ? _EmptyState(onCreatePurchase: () => _createNewPurchase(context, ref))
            : _PurchasesListView(purchases: purchases),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewPurchase(context, ref),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Nueva Compra'),
      ),
    );
  }

  Future<void> _createNewPurchase(BuildContext context, WidgetRef ref) async {
    // Por ahora solo creamos una compra simple
    // En una implementación completa, esto abriría un diálogo para seleccionar tienda y lista
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función próximamente - Crear nueva compra')),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreatePurchase;
  
  const _EmptyState({required this.onCreatePurchase});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            'No hay compras registradas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Registra tus compras con precios\npara llevar control de tus gastos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onCreatePurchase,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Primera Compra'),
          ),
        ],
      ),
    );
  }
}

class _PurchasesListView extends ConsumerWidget {
  final List<Purchase> purchases;
  
  const _PurchasesListView({required this.purchases});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(purchasesProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: purchases.length,
        itemBuilder: (context, index) => _PurchaseCard(purchase: purchases[index]),
      ),
    );
  }
}

class _PurchaseCard extends ConsumerWidget {
  final Purchase purchase;
  
  const _PurchaseCard({required this.purchase});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: const Icon(Icons.receipt),
        ),
        title: Text(purchase.storeName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(purchase.purchaseDate)),
            if (purchase.notes != null)
              Text(
                purchase.notes!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${purchase.currency} ${purchase.totalAmount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.outline,
            ),
          ],
        ),
        onTap: () => _navigateToPurchaseDetail(context),
      ),
    );
  }

  void _navigateToPurchaseDetail(BuildContext context) {
    // Navegar a detalle de compra
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función próximamente - Ver detalle de compra')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/shopping_providers.dart';
import '../model/store_purchase_models.dart';
import 'dialogs/purchase_item_dialog.dart';
import 'dialogs/shopping_checklist_dialog.dart';
import '../../services/receipt_pdf_service.dart';

class PurchaseDetailPage extends ConsumerStatefulWidget {
  final Purchase purchase;

  const PurchaseDetailPage({super.key, required this.purchase});

  @override
  ConsumerState<PurchaseDetailPage> createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends ConsumerState<PurchaseDetailPage> {
  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(purchaseItemsProvider(widget.purchase.id));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.purchase.storeName),
            Text(
              _formatDate(widget.purchase.purchaseDate),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          // Botón para usar lista base si existe
          if (widget.purchase.listId != null)
            IconButton(
              icon: const Icon(Icons.checklist),
              tooltip: 'Usar lista base',
              onPressed: () => _showChecklistDialog(context),
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit_notes',
                child: ListTile(
                  leading: Icon(Icons.note_add),
                  title: Text('Editar notas'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share_pdf',
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text('Compartir PDF'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Eliminar compra', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumen de la compra
          _PurchaseSummaryCard(purchase: widget.purchase),
          
          // Lista de productos
          Expanded(
            child: itemsAsync.when(
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
                      onPressed: () => ref.invalidate(purchaseItemsProvider(widget.purchase.id)),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (items) => items.isEmpty
                  ? _EmptyItemsState(
                      onAddItem: () => _showAddItemDialog(context),
                      onUseList: widget.purchase.listId != null 
                          ? () => _showChecklistDialog(context) 
                          : null,
                    )
                  : _PurchaseItemsList(
                      items: items,
                      purchaseId: widget.purchase.id,
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Agregar Producto'),
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    // Pre-cargar productos de la lista base si existe
    List<String> suggestedItems = [];
    if (widget.purchase.listId != null) {
      try {
        final listItemsAsync = ref.read(listItemsProvider(widget.purchase.listId!));
        final listItems = listItemsAsync.value;
        if (listItems != null) {
          suggestedItems = listItems.map((item) => item.name).toList();
        }
      } catch (e) {
        // Ignorar errores al cargar sugerencias
      }
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => PurchaseItemDialog(suggestedItems: suggestedItems),
    );

    if (result != null) {
      await ref.read(purchaseItemsProvider(widget.purchase.id).notifier).addItem(
        name: result['name'] as String,
        qty: result['qty'] as int,
        unitPrice: result['unitPrice'] as double,
        category: result['category'] as String?,
        notes: result['notes'] as String?,
      );
      
      // Refresh dashboard después de agregar item
      ref.invalidate(purchasesProvider);
      ref.invalidate(spendingByStoreProvider);
      ref.invalidate(monthlySpendingProvider);
      ref.invalidate(averagePricesProvider);
    }
  }

  Future<void> _showChecklistDialog(BuildContext context) async {
    if (widget.purchase.listId == null) return;
    
    try {
      final listsAsync = ref.read(shoppingListsProvider);
      final lists = listsAsync.value ?? [];
      final list = lists.firstWhere((l) => l.id == widget.purchase.listId);
      
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => ShoppingChecklistDialog(
          purchase: widget.purchase,
          list: list,
        ),
      );
      
      if (result == true) {
        // Refresh providers después de usar la lista
        ref.invalidate(purchaseItemsProvider(widget.purchase.id));
        ref.invalidate(purchasesProvider);
        ref.invalidate(spendingByStoreProvider);
        ref.invalidate(monthlySpendingProvider);
        ref.invalidate(averagePricesProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar la lista: $e')),
        );
      }
    }
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'edit_notes':
        _showEditNotesDialog(context);
        break;
      case 'share_pdf':
        _sharePurchaseAsPdf(context);
        break;
      case 'share':
        _sharePurchase(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  Future<void> _sharePurchaseAsPdf(BuildContext context) async {
    final itemsAsync = ref.read(purchaseItemsProvider(widget.purchase.id));
    final items = itemsAsync.value ?? [];
    
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos para generar el ticket')),
      );
      return;
    }

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando PDF...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await ReceiptPdfService.shareReceiptPdf(
        purchase: widget.purchase,
        items: items,
      );
      
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: $e')),
        );
      }
    }
  }

  Future<void> _showEditNotesDialog(BuildContext context) async {
    final controller = TextEditingController(text: widget.purchase.notes ?? '');
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Notas'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Agregar notas sobre esta compra...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null) {
      // TODO: Implementar actualización de notas de compra
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Función próximamente - Editar notas')),
      );
    }
  }

  void _sharePurchase(BuildContext context) {
    // TODO: Implementar compartir compra
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función próximamente - Compartir compra')),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Compra'),
        content: const Text('¿Estás seguro de que quieres eliminar esta compra? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(purchasesProvider.notifier).deletePurchase(widget.purchase.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compra eliminada')),
        );
        
        // Refresh dashboard
        ref.invalidate(spendingByStoreProvider);
        ref.invalidate(monthlySpendingProvider);
        ref.invalidate(averagePricesProvider);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _PurchaseItemsList extends ConsumerWidget {
  final List<PurchaseItem> items;
  final String purchaseId;
  
  const _PurchaseItemsList({
    required this.items,
    required this.purchaseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) => _PurchaseItemCard(
        item: items[index],
        purchaseId: purchaseId,
      ),
    );
  }
}

class _PurchaseItemCard extends ConsumerWidget {
  final PurchaseItem item;
  final String purchaseId;
  
  const _PurchaseItemCard({
    required this.item,
    required this.purchaseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cantidad en círculo
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${item.qty}',
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Información del producto (expandible)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₡${_formatNumberWithSeparator(item.unitPrice)} c/u',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (item.category != null) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.category!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      if (item.notes != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.notes!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Precio y menú (sin restricción de ancho)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₡${_formatNumberWithSeparator(item.totalPrice)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.more_vert,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (value) => _handleItemAction(context, ref, value),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              const Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'price_history',
                          child: Row(
                            children: [
                              Icon(Icons.history, size: 18, color: colorScheme.secondary),
                              const SizedBox(width: 8),
                              const Text('Ver historial'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, size: 18, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// OPCIÓN ALTERNATIVA: ListTile mejorado (comenta el código anterior si usas esta versión)
/*
class _PurchaseItemCard extends ConsumerWidget {
  final PurchaseItem item;
  final String purchaseId;
  
  const _PurchaseItemCard({
    required this.item,
    required this.purchaseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${item.qty}',
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text(
              '₡${_formatNumberWithSeparator(item.unitPrice)} c/u',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.category != null) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.category!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
            if (item.notes != null) ...[
              const SizedBox(height: 2),
              Text(
                item.notes!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₡${_formatNumberWithSeparator(item.totalPrice)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_vert,
                color: colorScheme.onSurfaceVariant,
              ),
              onSelected: (value) => _handleItemAction(context, ref, value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'price_history',
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 18, color: colorScheme.secondary),
                      const SizedBox(width: 8),
                      const Text('Ver historial'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // ... resto del código igual
}
*/
  String _formatNumberWithSeparator(double number) {
    final intPart = number.round();
    final str = intPart.toString();
    
    if (str.length <= 3) return str;
    
    String result = '';
    int count = 0;
    
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result'; // Punto como separador estilo Costa Rica
        count = 0;
      }
      result = str[i] + result;
      count++;
    }
    
    return result;
  }

  Future<void> _handleItemAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'edit':
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => PurchaseItemDialog(
            initialName: item.name,
            initialQty: item.qty,
            initialUnitPrice: item.unitPrice,
            initialCategory: item.category,
            initialNotes: item.notes,
          ),
        );
        if (result != null) {
          await ref.read(purchaseItemsProvider(purchaseId).notifier).updateItem(
            id: item.id,
            name: result['name'] as String,
            qty: result['qty'] as int,
            unitPrice: result['unitPrice'] as double,
            category: result['category'] as String?,
            notes: result['notes'] as String?,
          );
          
          // Refresh dashboard después de editar
          ref.invalidate(purchasesProvider);
          ref.invalidate(spendingByStoreProvider);
          ref.invalidate(monthlySpendingProvider);
          ref.invalidate(averagePricesProvider);
        }
        break;
        
      case 'price_history':
        _showPriceHistory(context, ref);
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
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
        
        if (confirmed == true) {
          await ref.read(purchaseItemsProvider(purchaseId).notifier).deleteItem(item.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Producto "${item.name}" eliminado')),
            );
            
            // Refresh dashboard después de eliminar
            ref.invalidate(purchasesProvider);
            ref.invalidate(spendingByStoreProvider);
            ref.invalidate(monthlySpendingProvider);
            ref.invalidate(averagePricesProvider);
          }
        }
        break;
    }
  }

  void _showPriceHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _PriceHistoryDialog(itemName: item.name),
    );
  }
}

class _PriceHistoryDialog extends ConsumerWidget {
  final String itemName;

  const _PriceHistoryDialog({required this.itemName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(priceHistoryProvider(itemName));

    return AlertDialog(
      title: Text('Historial de $itemName'),
      content: SizedBox(
        width: double.maxFinite,
        child: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
          data: (history) {
            if (history.isEmpty) {
              return const Text('No hay historial de precios para este producto');
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Últimas ${history.length} compras:'),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final record = history[index];
                      return ListTile(
                        leading: Icon(Icons.store, color: Theme.of(context).colorScheme.primary),
                        title: Text(record.storeName),
                        subtitle: Text(_formatDate(record.purchaseDate)),
                        trailing: Text(
                          '₡${_formatNumberWithSeparator(record.price)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Función helper para formatear números con separador de miles
  String _formatNumberWithSeparator(double number) {
    final intPart = number.round();
    final str = intPart.toString();
    
    if (str.length <= 3) return str;
    
    String result = '';
    int count = 0;
    
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result'; // Punto como separador
        count = 0;
      }
      result = str[i] + result;
      count++;
    }
    
    return result;
  }
}

class _PurchaseSummaryCard extends ConsumerWidget {
  final Purchase purchase;

  const _PurchaseSummaryCard({required this.purchase});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(purchaseItemsProvider(purchase.id));
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Resumen de Compra',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            itemsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => const Text('Error cargando resumen'),
              data: (items) {
                final totalItems = items.fold(0, (sum, item) => sum + item.qty);
                final calculatedTotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
                
                return Column(
                  children: [
                    _SummaryRow('Tienda:', purchase.storeName),
                    _SummaryRow('Fecha:', _formatDate(purchase.purchaseDate)),
                    _SummaryRow('Total de productos:', '$totalItems'),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${purchase.currency} ${_formatNumberWithSeparator(calculatedTotal)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    if (purchase.notes != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          purchase.notes!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _SummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Función helper para formatear números con separador de miles
  String _formatNumberWithSeparator(double number) {
    final intPart = number.round();
    final str = intPart.toString();
    
    if (str.length <= 3) return str;
    
    String result = '';
    int count = 0;
    
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result'; // Usa punto como separador (estilo Costa Rica)
        count = 0;
      }
      result = str[i] + result;
      count++;
    }
    
    return result;
  }
}

class _EmptyItemsState extends StatelessWidget {
  final VoidCallback onAddItem;
  final VoidCallback? onUseList;
  
  const _EmptyItemsState({
    required this.onAddItem,
    this.onUseList,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView( // Permitir scroll si es necesario
      padding: const EdgeInsets.all(16), // Padding para evitar tocar bordes
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Solo el tamaño necesario
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100, // Reducir tamaño del icono
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16), // Reducir espacios
            Text(
              'Sin productos aún',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega los productos que compraste\ncon sus precios',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24), // Reducir espacio
            
            // Botones en una columna compacta
            if (onUseList != null) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onUseList,
                  icon: const Icon(Icons.checklist),
                  label: const Text('Usar Lista Base'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'o',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAddItem,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Agregar Manualmente'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
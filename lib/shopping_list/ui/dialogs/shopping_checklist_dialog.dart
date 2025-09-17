import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/shopping_providers.dart';
import '../../model/shopping_list.dart';
import '../../model/store_purchase_models.dart';

class ShoppingChecklistDialog extends ConsumerStatefulWidget {
  final Purchase purchase;
  final ShoppingList list;

  const ShoppingChecklistDialog({
    super.key,
    required this.purchase,
    required this.list,
  });

  @override
  ConsumerState<ShoppingChecklistDialog> createState() => _ShoppingChecklistDialogState();
}

class _ShoppingChecklistDialogState extends ConsumerState<ShoppingChecklistDialog> {
  final Map<String, bool> _checkedItems = {};
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, String> _unitTypes = {}; // 'kg' o 'unidad'
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final listItemsAsync = ref.read(listItemsProvider(widget.list.id));
    final items = listItemsAsync.value ?? [];
    
    for (final item in items) {
      _checkedItems[item.id] = false;
      _quantityControllers[item.id] = TextEditingController(text: item.qty.toString());
      _priceControllers[item.id] = TextEditingController();
      _unitTypes[item.id] = 'unidad'; // Default
    }
  }

  @override
  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listItemsAsync = ref.watch(listItemsProvider(widget.list.id));

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.checklist, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Completar: ${widget.list.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            
            // Lista de items
            Expanded(
              child: listItemsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('La lista está vacía'));
                  }
                  
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isChecked = _checkedItems[item.id] ?? false;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Checkbox y nombre
                              Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        _checkedItems[item.id] = value ?? false;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: TextStyle(
                                        decoration: isChecked 
                                            ? TextDecoration.lineThrough 
                                            : null,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (item.category != null)
                                    Chip(
                                      label: Text(item.category!),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                ],
                              ),
                              
                              if (isChecked) ...[
                                const SizedBox(height: 8),
                                // Cantidad y unidad
                                Row(
                                  children: [
                                    // Cantidad
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: _quantityControllers[item.id],
                                        decoration: const InputDecoration(
                                          labelText: 'Cantidad',
                                          isDense: true,
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    
                                    // Tipo de unidad
                                    Expanded(
                                      flex: 2,
                                      child: DropdownButtonFormField<String>(
                                        value: _unitTypes[item.id],
                                        decoration: const InputDecoration(
                                          labelText: 'Unidad',
                                          isDense: true,
                                        ),
                                        items: const [
                                          DropdownMenuItem(value: 'unidad', child: Text('Unidad')),
                                          DropdownMenuItem(value: 'kg', child: Text('Kg')),
                                          DropdownMenuItem(value: 'gramos', child: Text('Gramos')),
                                          DropdownMenuItem(value: 'litros', child: Text('Litros')),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _unitTypes[item.id] = value ?? 'unidad';
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    
                                    // Precio
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: _priceControllers[item.id],
                                        decoration: const InputDecoration(
                                          labelText: 'Precio (₡)',
                                          isDense: true,
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            const Divider(),
            
            // Resumen y botones
            Row(
              children: [
                Text(
                  'Items seleccionados: ${_checkedItems.values.where((checked) => checked).length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saveSelectedItems,
                  child: const Text('Guardar Compra'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSelectedItems() async {
    final selectedItems = <Map<String, dynamic>>[];
    
    _checkedItems.forEach((itemId, isChecked) {
      if (isChecked) {
        final quantityText = _quantityControllers[itemId]?.text ?? '1';
        final priceText = _priceControllers[itemId]?.text ?? '0';
        
        final quantity = double.tryParse(quantityText) ?? 1.0;
        final unitPrice = double.tryParse(priceText) ?? 0.0;
        final unitType = _unitTypes[itemId] ?? 'unidad';
        
        // Buscar el nombre del item
        final listItemsAsync = ref.read(listItemsProvider(widget.list.id));
        final items = listItemsAsync.value ?? [];
        final item = items.firstWhere((i) => i.id == itemId);
        
        selectedItems.add({
          'name': item.name,
          'qty': quantity.toInt(),
          'unitPrice': unitPrice,
          'category': item.category,
          'unitType': unitType,
          'notes': unitType != 'unidad' ? 'Comprado por $unitType' : null,
        });
      }
    });

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un producto')),
      );
      return;
    }

    try {
      // Agregar cada item seleccionado a la compra
      for (final itemData in selectedItems) {
        await ref.read(purchaseItemsProvider(widget.purchase.id).notifier).addItem(
          name: itemData['name'] as String,
          qty: itemData['qty'] as int,
          unitPrice: itemData['unitPrice'] as double,
          category: itemData['category'] as String?,
          notes: itemData['notes'] as String?,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Retornar true para indicar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${selectedItems.length} productos agregados a la compra')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar productos: $e')),
        );
      }
    }
  }
}
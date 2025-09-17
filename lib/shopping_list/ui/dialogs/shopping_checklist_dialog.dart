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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600; // Detección de pantalla pequeña

    return Dialog(
      insetPadding: const EdgeInsets.all(16), // Márgenes más pequeños en móvil
      child: Container(
        width: double.infinity, // Usar todo el ancho disponible
        height: MediaQuery.of(context).size.height * 0.85, // Aumentar altura ligeramente
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.checklist, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Completar: ${widget.list.name}',
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                ],
              ),
            ),
            
            // Lista de items (expandible)
            Expanded(
              child: listItemsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('La lista está vacía'));
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                    visualDensity: VisualDensity.compact,
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        item.category!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              
                              if (isChecked) ...[
                                const SizedBox(height: 12),
                                // Layout responsivo para campos de entrada
                                if (isSmallScreen) 
                                  // Móvil: Layout vertical en columnas
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _quantityControllers[item.id],
                                              decoration: const InputDecoration(
                                                labelText: 'Cantidad',
                                                isDense: true,
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: DropdownButtonFormField<String>(
                                              value: _unitTypes[item.id],
                                              decoration: const InputDecoration(
                                                labelText: 'Unidad',
                                                isDense: true,
                                                border: OutlineInputBorder(),
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
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _priceControllers[item.id],
                                        decoration: const InputDecoration(
                                          labelText: 'Precio Total (CRC)',
                                          isDense: true,
                                          border: OutlineInputBorder(),
                                          prefixText: '₡ ',
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                        ],
                                      ),
                                    ],
                                  )
                                else 
                                  // Tablet/Desktop: Layout horizontal
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: _quantityControllers[item.id],
                                          decoration: const InputDecoration(
                                            labelText: 'Cantidad',
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<String>(
                                          value: _unitTypes[item.id],
                                          decoration: const InputDecoration(
                                            labelText: 'Unidad',
                                            isDense: true,
                                            border: OutlineInputBorder(),
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
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: _priceControllers[item.id],
                                          decoration: const InputDecoration(
                                            labelText: 'Precio (CRC)',
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                            prefixText: '₡ ',
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
            
            // Footer con layout responsivo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Contador de items
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Items seleccionados: ${_checkedItems.values.where((checked) => checked).length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Botones responsivos
                  if (isSmallScreen)
                    // Móvil: Botones en columna
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _saveSelectedItems,
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar Compra'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    // Tablet/Desktop: Botones en fila
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: _saveSelectedItems,
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar Compra'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
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
                  Text('Guardando productos...'),
                ],
              ),
            ),
          ),
        ),
      );

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
        Navigator.of(context).pop(); // Cerrar loading
        Navigator.of(context).pop(true); // Cerrar diálogo principal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedItems.length} productos agregados a la compra'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar productos: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
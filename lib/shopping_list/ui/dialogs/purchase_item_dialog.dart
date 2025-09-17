import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PurchaseItemDialog extends StatefulWidget {
  final String? initialName;
  final int? initialQty;
  final double? initialUnitPrice;
  final String? initialCategory;
  final String? initialNotes;
  final List<String> suggestedItems;
  
  const PurchaseItemDialog({
    super.key,
    this.initialName,
    this.initialQty,
    this.initialUnitPrice,
    this.initialCategory,
    this.initialNotes,
    this.suggestedItems = const [],
  });

  @override
  State<PurchaseItemDialog> createState() => _PurchaseItemDialogState();
}

class _PurchaseItemDialogState extends State<PurchaseItemDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _qtyController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _notesController;
  final _formKey = GlobalKey<FormState>();

  final List<String> _commonCategories = [
    'Frutas y Verduras',
    'Lácteos',
    'Carnes',
    'Panadería',
    'Bebidas',
    'Limpieza',
    'Higiene Personal',
    'Congelados',
    'Conservas',
    'Snacks',
  ];

  double get _totalPrice {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
    return qty * unitPrice;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _qtyController = TextEditingController(text: (widget.initialQty ?? 1).toString());
    _unitPriceController = TextEditingController(text: widget.initialUnitPrice?.toString() ?? '');
    _categoryController = TextEditingController(text: widget.initialCategory ?? '');
    _notesController = TextEditingController(text: widget.initialNotes ?? '');

    // Listeners para actualizar el total en tiempo real
    _qtyController.addListener(_updateTotal);
    _unitPriceController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _unitPriceController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    setState(() {}); // Actualizar el total mostrado
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop({
        'name': _nameController.text.trim(),
        'qty': int.tryParse(_qtyController.text) ?? 1,
        'unitPrice': double.tryParse(_unitPriceController.text) ?? 0.0,
        'category': _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Editar Producto' : 'Agregar Producto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nombre del producto con autocompletado
              if (widget.suggestedItems.isNotEmpty)
                Autocomplete<String>(
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return widget.suggestedItems.where((item) =>
                        item.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (value) {
                    _nameController.text = value;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    // Sincronizar con nuestro controlador
                    controller.text = _nameController.text;
                    controller.addListener(() {
                      _nameController.text = controller.text;
                    });
                    
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del producto',
                        hintText: 'Ej: Leche, Pan, Manzanas...',
                        prefixIcon: Icon(Icons.shopping_basket),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el nombre del producto';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => onFieldSubmitted(),
                    );
                  },
                )
              else
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto',
                    hintText: 'Ej: Leche, Pan, Manzanas...',
                    prefixIcon: Icon(Icons.shopping_basket),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre del producto';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),

              // Cantidad y precio en fila
              Row(
                children: [
                  // Cantidad
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _qtyController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        final qty = int.tryParse(value ?? '');
                        if (qty == null || qty <= 0) {
                          return 'Cantidad válida';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Precio unitario
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _unitPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio c/u (₡)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      validator: (value) {
                        final price = double.tryParse(value ?? '');
                        if (price == null || price < 0) {
                          return 'Precio válido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total calculado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₡${_totalPrice.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Categoría con dropdown
              DropdownButtonFormField<String>(
                value: _categoryController.text.isEmpty ? null : _categoryController.text,
                decoration: const InputDecoration(
                  labelText: 'Categoría (opcional)',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _commonCategories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryController.text = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 16),

              // Notas opcionales
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  hintText: 'Marca, oferta especial, etc...',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Actualizar' : 'Agregar'),
        ),
      ],
    );
  }
}
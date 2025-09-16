import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ListItemDialog extends StatefulWidget {
  final String? initialName;
  final int? initialQty;
  final String? initialCategory;
  
  const ListItemDialog({
    super.key,
    this.initialName,
    this.initialQty,
    this.initialCategory,
  });

  @override
  State<ListItemDialog> createState() => _ListItemDialogState();
}

class _ListItemDialogState extends State<ListItemDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _qtyController;
  late final TextEditingController _categoryController;
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _qtyController = TextEditingController(text: (widget.initialQty ?? 1).toString());
    _categoryController = TextEditingController(text: widget.initialCategory ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop({
        'name': _nameController.text.trim(),
        'qty': int.tryParse(_qtyController.text) ?? 1,
        'category': _categoryController.text.trim().isEmpty 
            ? null 
            : _categoryController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                hintText: 'Ej: Leche, Pan, Manzanas...',
              ),
              autofocus: true,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _qtyController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                hintText: '1',
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                final qty = int.tryParse(value ?? '');
                if (qty == null || qty <= 0) {
                  return 'Ingresa una cantidad válida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownMenu<String>(
              controller: _categoryController,
              label: const Text('Categoría (opcional)'),
              hintText: 'Selecciona o escribe una categoría',
              enableSearch: true,
              expandedInsets: EdgeInsets.zero,
              dropdownMenuEntries: _commonCategories
                  .map((category) => DropdownMenuEntry<String>(
                        value: category,
                        label: category,
                      ))
                  .toList(),
              onSelected: (String? value) {
                if (value != null) {
                  _categoryController.text = value;
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Guardar' : 'Agregar'),
        ),
      ],
    );
  }
}
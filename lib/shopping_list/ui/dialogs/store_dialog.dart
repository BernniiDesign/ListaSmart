import 'package:flutter/material.dart';

class StoreDialog extends StatefulWidget {
  final String? initialName;
  final String? initialLocation;
  
  const StoreDialog({
    super.key,
    this.initialName,
    this.initialLocation,
  });

  @override
  State<StoreDialog> createState() => _StoreDialogState();
}

class _StoreDialogState extends State<StoreDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _locationController = TextEditingController(text: widget.initialLocation ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop({
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Editar Tienda' : 'Nueva Tienda'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la tienda',
                hintText: 'Ej: Walmart, AutoMercado, Maxi Palí...',
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
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Ubicación (opcional)',
                hintText: 'Ej: Centro Comercial, Dirección...',
                prefixIcon: Icon(Icons.location_on),
              ),
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) => _submit(),
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
          child: Text(isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}
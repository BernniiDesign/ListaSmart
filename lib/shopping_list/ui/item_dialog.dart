import 'package:flutter/material.dart';

class ItemDialog extends StatefulWidget {
  final String? initialName;
  final int? initialQty;
  const ItemDialog({super.key, this.initialName, this.initialQty});

  @override
  State<ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<ItemDialog> {
  late final TextEditingController _name;
  late final TextEditingController _qty;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName ?? '');
    _qty = TextEditingController(text: (widget.initialQty ?? 1).toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    final qty = int.tryParse(_qty.text) ?? 1;
    if (name.isEmpty) return;
    Navigator.of(context).pop({'name': name, 'qty': qty});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'Nuevo ítem' : 'Editar ítem'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nombre del producto'),
            autofocus: true,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _qty,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cantidad'),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}

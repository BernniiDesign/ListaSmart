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

class _PurchaseItemDialogState extends State<PurchaseItemDialog>
    with TickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final TextEditingController _qtyController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _notesController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late AnimationController _animationController;
  late AnimationController _totalAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _totalColorAnimation;

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

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _totalAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _totalColorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.green,
    ).animate(_totalAnimationController);

    // Listeners para actualizar el total en tiempo real
    _qtyController.addListener(_updateTotal);
    _unitPriceController.addListener(_updateTotal);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _totalAnimationController.dispose();
    _nameController.dispose();
    _qtyController.dispose();
    _unitPriceController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    setState(() {});
    _totalAnimationController.forward().then((_) {
      _totalAnimationController.reverse();
    });
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      // Pequeña demora para mostrar el loading
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.of(context).pop({
          'name': _nameController.text.trim(),
          'qty': int.tryParse(_qtyController.text) ?? 1,
          'unitPrice': double.tryParse(_unitPriceController.text) ?? 0.0,
          'category': _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
          'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.initialName != null;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 550,
                    maxHeight: 700,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.surface,
                        colorScheme.surface.withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.25),
                        blurRadius: 35,
                        offset: const Offset(0, 25),
                      ),
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.1),
                        blurRadius: 50,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header dinámico
                      _buildHeader(isEditing, colorScheme, theme),
                      
                      // Contenido scrolleable
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(28),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildProductNameField(),
                                const SizedBox(height: 20),
                                _buildQuantityAndPriceFields(),
                                const SizedBox(height: 24),
                                _buildTotalCard(),
                                const SizedBox(height: 20),
                                _buildCategoryField(),
                                const SizedBox(height: 20),
                                _buildNotesField(),
                                const SizedBox(height: 32),
                                _buildActionButtons(isEditing),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isEditing, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 0.1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    isEditing ? Icons.edit_rounded : Icons.add_shopping_cart_rounded,
                    color: colorScheme.onPrimary,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Editar Producto' : 'Agregar Producto',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditing 
                      ? 'Modifica la información del producto'
                      : 'Agrega un nuevo producto con precio',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductNameField() {
    if (widget.suggestedItems.isNotEmpty) {
      return Autocomplete<String>(
        optionsBuilder: (textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return widget.suggestedItems.where((item) =>
              item.toLowerCase().contains(textEditingValue.text.toLowerCase()));
        },
        onSelected: (value) => _nameController.text = value,
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          controller.text = _nameController.text;
          controller.addListener(() => _nameController.text = controller.text);
          
          return _buildTextField(
            controller: controller,
            focusNode: focusNode,
            label: 'Nombre del producto',
            hint: 'Ej: Leche, Pan, Manzanas...',
            icon: Icons.shopping_basket_rounded,
            color: Theme.of(context).colorScheme.primary,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa el nombre del producto';
              }
              return null;
            },
            onSubmitted: (_) => onFieldSubmitted(),
          );
        },
      );
    } else {
      return _buildTextField(
        controller: _nameController,
        label: 'Nombre del producto',
        hint: 'Ej: Leche, Pan, Manzanas...',
        icon: Icons.shopping_basket_rounded,
        color: Theme.of(context).colorScheme.primary,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Ingresa el nombre del producto';
          }
          return null;
        },
      );
    }
  }

  Widget _buildQuantityAndPriceFields() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildTextField(
            controller: _qtyController,
            label: 'Cantidad',
            hint: '1',
            icon: Icons.numbers_rounded,
            color: Theme.of(context).colorScheme.secondary,
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
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: _buildTextField(
            controller: _unitPriceController,
            label: 'Precio c/u (₡)',
            hint: '0.00',
            icon: Icons.attach_money_rounded,
            color: Theme.of(context).colorScheme.tertiary,
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
    );
  }

  Widget _buildTotalCard() {
    return AnimatedBuilder(
      animation: _totalColorAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (_totalColorAnimation.value ?? Theme.of(context).colorScheme.primary)
                    .withOpacity(0.15),
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (_totalColorAnimation.value ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (_totalColorAnimation.value ?? Theme.of(context).colorScheme.primary)
                    .withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total de la compra',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cantidad × Precio unitario',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0, end: _totalPrice),
                builder: (context, value, child) {
                  return Text(
                    '₡${_formatNumberWithSeparator(value)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _totalColorAnimation.value ?? Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      value: _categoryController.text.isEmpty ? null : _categoryController.text,
      decoration: InputDecoration(
        labelText: 'Categoría (opcional)',
        hintText: 'Selecciona una categoría...',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.category_rounded,
            color: Theme.of(context).colorScheme.secondary,
            size: 20,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
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
    );
  }

  Widget _buildNotesField() {
    return _buildTextField(
      controller: _notesController,
      label: 'Notas (opcional)',
      hint: 'Marca, oferta especial, etc...',
      icon: Icons.note_rounded,
      color: Theme.of(context).colorScheme.outline,
      maxLines: 2,
      minLines: 1,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    int maxLines = 1,
    int minLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        minLines: minLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: TextCapitalization.words,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: color.withOpacity(0.05),
          labelStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isEditing) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FilledButton(
              onPressed: _isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isEditing ? Icons.update_rounded : Icons.add_shopping_cart_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? 'Actualizar' : 'Agregar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumberWithSeparator(double number) {
    final intPart = number.round();
    final str = intPart.toString();
    
    if (str.length <= 3) return str;
    
    String result = '';
    int count = 0;
    
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result';
        count = 0;
      }
      result = str[i] + result;
      count++;
    }
    
    return result;
  }
}
class ShoppingList {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final bool isTemplate;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingList({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.isTemplate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShoppingList.fromMap(Map<String, dynamic> map) => ShoppingList(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        isTemplate: map['is_template'] as bool,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );

  Map<String, dynamic> toInsert() => {
        'name': name,
        'description': description,
        'is_template': isTemplate,
      };

  ShoppingList copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    bool? isTemplate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ShoppingList(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        description: description ?? this.description,
        isTemplate: isTemplate ?? this.isTemplate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class ShoppingListItem {
  final String id;
  final String listId;
  final String name;
  final int qty;
  final String? category;
  final DateTime createdAt;

  ShoppingListItem({
    required this.id,
    required this.listId,
    required this.name,
    required this.qty,
    this.category,
    required this.createdAt,
  });

  factory ShoppingListItem.fromMap(Map<String, dynamic> map) => ShoppingListItem(
        id: map['id'] as String,
        listId: map['list_id'] as String,
        name: map['name'] as String,
        qty: (map['qty'] as num).toInt(),
        category: map['category'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toInsert() => {
        'list_id': listId,
        'name': name,
        'qty': qty,
        'category': category,
      };

  ShoppingListItem copyWith({
    String? id,
    String? listId,
    String? name,
    int? qty,
    String? category,
    DateTime? createdAt,
  }) =>
      ShoppingListItem(
        id: id ?? this.id,
        listId: listId ?? this.listId,
        name: name ?? this.name,
        qty: qty ?? this.qty,
        category: category ?? this.category,
        createdAt: createdAt ?? this.createdAt,
      );
}
class GroceryItem {
  final String id;
  final String name;
  final int qty;
  final bool done;

  GroceryItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.done,
  });

  factory GroceryItem.fromMap(Map<String, dynamic> map) => GroceryItem(
        id: map['id'] as String,
        name: map['name'] as String,
        qty: (map['qty'] as num?)?.toInt() ?? 1,
        done: map['done'] as bool? ?? false,
      );

  Map<String, dynamic> toInsert() => {
        'name': name,
        'qty': qty,
        'done': done,
      };

  GroceryItem copyWith({String? id, String? name, int? qty, bool? done}) =>
      GroceryItem(
        id: id ?? this.id,
        name: name ?? this.name,
        qty: qty ?? this.qty,
        done: done ?? this.done,
      );
}

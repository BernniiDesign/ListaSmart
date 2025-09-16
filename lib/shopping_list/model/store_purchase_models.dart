class Store {
  final String id;
  final String userId;
  final String name;
  final String? location;
  final DateTime createdAt;

  Store({
    required this.id,
    required this.userId,
    required this.name,
    this.location,
    required this.createdAt,
  });

  factory Store.fromMap(Map<String, dynamic> map) => Store(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        name: map['name'] as String,
        location: map['location'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toInsert() => {
        'name': name,
        'location': location,
      };

  Store copyWith({
    String? id,
    String? userId,
    String? name,
    String? location,
    DateTime? createdAt,
  }) =>
      Store(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        location: location ?? this.location,
        createdAt: createdAt ?? this.createdAt,
      );
}

class Purchase {
  final String id;
  final String userId;
  final String? listId;
  final String? storeId;
  final String storeName;
  final double totalAmount;
  final String currency;
  final DateTime purchaseDate;
  final String? notes;
  final DateTime createdAt;

  Purchase({
    required this.id,
    required this.userId,
    this.listId,
    this.storeId,
    required this.storeName,
    required this.totalAmount,
    required this.currency,
    required this.purchaseDate,
    this.notes,
    required this.createdAt,
  });

  factory Purchase.fromMap(Map<String, dynamic> map) => Purchase(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        listId: map['list_id'] as String?,
        storeId: map['store_id'] as String?,
        storeName: map['store_name'] as String,
        totalAmount: (map['total_amount'] as num).toDouble(),
        currency: map['currency'] as String,
        purchaseDate: DateTime.parse(map['purchase_date'] as String),
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toInsert() => {
        'list_id': listId,
        'store_id': storeId,
        'store_name': storeName,
        'total_amount': totalAmount,
        'currency': currency,
        'purchase_date': purchaseDate.toIso8601String(),
        'notes': notes,
      };

  Purchase copyWith({
    String? id,
    String? userId,
    String? listId,
    String? storeId,
    String? storeName,
    double? totalAmount,
    String? currency,
    DateTime? purchaseDate,
    String? notes,
    DateTime? createdAt,
  }) =>
      Purchase(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        listId: listId ?? this.listId,
        storeId: storeId ?? this.storeId,
        storeName: storeName ?? this.storeName,
        totalAmount: totalAmount ?? this.totalAmount,
        currency: currency ?? this.currency,
        purchaseDate: purchaseDate ?? this.purchaseDate,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
}

class PurchaseItem {
  final String id;
  final String purchaseId;
  final String name;
  final int qty;
  final double unitPrice;
  final double totalPrice;
  final String? category;
  final String? notes;
  final DateTime createdAt;

  PurchaseItem({
    required this.id,
    required this.purchaseId,
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.totalPrice,
    this.category,
    this.notes,
    required this.createdAt,
  });

  factory PurchaseItem.fromMap(Map<String, dynamic> map) => PurchaseItem(
        id: map['id'] as String,
        purchaseId: map['purchase_id'] as String,
        name: map['name'] as String,
        qty: (map['qty'] as num).toInt(),
        unitPrice: (map['unit_price'] as num).toDouble(),
        totalPrice: (map['total_price'] as num).toDouble(),
        category: map['category'] as String?,
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toInsert() => {
        'purchase_id': purchaseId,
        'name': name,
        'qty': qty,
        'unit_price': unitPrice,
        'total_price': totalPrice,
        'category': category,
        'notes': notes,
      };

  PurchaseItem copyWith({
    String? id,
    String? purchaseId,
    String? name,
    int? qty,
    double? unitPrice,
    double? totalPrice,
    String? category,
    String? notes,
    DateTime? createdAt,
  }) =>
      PurchaseItem(
        id: id ?? this.id,
        purchaseId: purchaseId ?? this.purchaseId,
        name: name ?? this.name,
        qty: qty ?? this.qty,
        unitPrice: unitPrice ?? this.unitPrice,
        totalPrice: totalPrice ?? this.totalPrice,
        category: category ?? this.category,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
}

class PriceHistory {
  final String id;
  final String userId;
  final String itemName;
  final String? storeId;
  final String storeName;
  final double price;
  final String currency;
  final DateTime purchaseDate;
  final DateTime createdAt;

  PriceHistory({
    required this.id,
    required this.userId,
    required this.itemName,
    this.storeId,
    required this.storeName,
    required this.price,
    required this.currency,
    required this.purchaseDate,
    required this.createdAt,
  });

  factory PriceHistory.fromMap(Map<String, dynamic> map) => PriceHistory(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        itemName: map['item_name'] as String,
        storeId: map['store_id'] as String?,
        storeName: map['store_name'] as String,
        price: (map['price'] as num).toDouble(),
        currency: map['currency'] as String,
        purchaseDate: DateTime.parse(map['purchase_date'] as String),
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
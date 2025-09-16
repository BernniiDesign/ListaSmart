import '../data/shopping_data_source.dart';
import '../model/shopping_list.dart';
import '../model/store_purchase_models.dart';

class ShoppingRepository {
  final ShoppingDataSource _dataSource;

  ShoppingRepository(this._dataSource);

  // Shopping Lists
  Future<List<ShoppingList>> getShoppingLists() => _dataSource.fetchShoppingLists();
  
  Future<ShoppingList> createShoppingList(String name, {String? description}) =>
      _dataSource.createShoppingList(name, description: description);
  
  Future<void> updateShoppingList(String id, String name, {String? description}) =>
      _dataSource.updateShoppingList(id, name, description: description);
  
  Future<void> deleteShoppingList(String id) => _dataSource.deleteShoppingList(id);

  // Shopping List Items
  Future<List<ShoppingListItem>> getListItems(String listId) =>
      _dataSource.fetchListItems(listId);
  
  Future<ShoppingListItem> addListItem(String listId, String name, int qty, {String? category}) =>
      _dataSource.addListItem(listId, name, qty, category: category);
  
  Future<void> updateListItem(String id, String name, int qty, {String? category}) =>
      _dataSource.updateListItem(id, name, qty, category: category);
  
  Future<void> deleteListItem(String id) => _dataSource.deleteListItem(id);

  // Stores
  Future<List<Store>> getStores() => _dataSource.fetchStores();
  
  Future<Store> createStore(String name, {String? location}) =>
      _dataSource.createStore(name, location: location);
  
  Future<void> updateStore(String id, String name, {String? location}) =>
      _dataSource.updateStore(id, name, location: location);
  
  Future<void> deleteStore(String id) => _dataSource.deleteStore(id);

  // Purchases
  Future<List<Purchase>> getPurchases({int limit = 50}) =>
      _dataSource.fetchPurchases(limit: limit);
  
  Future<Purchase> createPurchase({
    String? listId,
    String? storeId,
    required String storeName,
    String? notes,
  }) => _dataSource.createPurchase(
        listId: listId,
        storeId: storeId,
        storeName: storeName,
        notes: notes,
      );
  
  Future<void> deletePurchase(String id) => _dataSource.deletePurchase(id);

  // Purchase Items
  Future<List<PurchaseItem>> getPurchaseItems(String purchaseId) =>
      _dataSource.fetchPurchaseItems(purchaseId);
  
  Future<PurchaseItem> addPurchaseItem({
    required String purchaseId,
    required String name,
    required int qty,
    required double unitPrice,
    String? category,
    String? notes,
  }) => _dataSource.addPurchaseItem(
        purchaseId: purchaseId,
        name: name,
        qty: qty,
        unitPrice: unitPrice,
        category: category,
        notes: notes,
      );
  
  Future<void> updatePurchaseItem({
    required String id,
    required String name,
    required int qty,
    required double unitPrice,
    String? category,
    String? notes,
  }) => _dataSource.updatePurchaseItem(
        id: id,
        name: name,
        qty: qty,
        unitPrice: unitPrice,
        category: category,
        notes: notes,
      );
  
  Future<void> deletePurchaseItem(String id) => _dataSource.deletePurchaseItem(id);

  // Analytics
  Future<List<PriceHistory>> getPriceHistory(String itemName) =>
      _dataSource.fetchPriceHistory(itemName);
  
  Future<Map<String, dynamic>> getSpendingByStore() =>
      _dataSource.fetchSpendingByStore();
  
  Future<Map<String, dynamic>> getAveragePrices() =>
      _dataSource.fetchAveragePrices();
  
  Future<Map<String, dynamic>> getMonthlySpending() =>
      _dataSource.fetchMonthlySpending();
}
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../supabase/supabase_init.dart';
import '../model/shopping_list.dart';
import '../model/store_purchase_models.dart';

class ShoppingDataSource {
  final SupabaseClient _client;
  
  ShoppingDataSource({SupabaseClient? client}) : _client = client ?? supabase;

  String get _userId => _client.auth.currentUser!.id;

  // SHOPPING LISTS
  Future<List<ShoppingList>> fetchShoppingLists() async {
    final res = await _client
        .from('shopping_lists')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
    return (res as List).map((e) => ShoppingList.fromMap(e)).toList();
  }

  Future<ShoppingList> createShoppingList(String name, {String? description}) async {
    final data = await _client
        .from('shopping_lists')
        .insert({
          'user_id': _userId,
          'name': name,
          'description': description,
          'is_template': true,
        })
        .select()
        .single();
    return ShoppingList.fromMap(data);
  }

  Future<void> updateShoppingList(String id, String name, {String? description}) async {
    await _client
        .from('shopping_lists')
        .update({
          'name': name,
          'description': description,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  Future<void> deleteShoppingList(String id) async {
    await _client.from('shopping_lists').delete().eq('id', id);
  }

  // SHOPPING LIST ITEMS
  Future<List<ShoppingListItem>> fetchListItems(String listId) async {
    final res = await _client
        .from('shopping_list_items')
        .select()
        .eq('list_id', listId)
        .order('created_at', ascending: true);
    return (res as List).map((e) => ShoppingListItem.fromMap(e)).toList();
  }

  Future<ShoppingListItem> addListItem(String listId, String name, int qty, {String? category}) async {
    final data = await _client
        .from('shopping_list_items')
        .insert({
          'list_id': listId,
          'name': name,
          'qty': qty,
          'category': category,
        })
        .select()
        .single();
    return ShoppingListItem.fromMap(data);
  }

  Future<void> updateListItem(String id, String name, int qty, {String? category}) async {
    await _client
        .from('shopping_list_items')
        .update({
          'name': name,
          'qty': qty,
          'category': category,
        })
        .eq('id', id);
  }

  Future<void> deleteListItem(String id) async {
    await _client.from('shopping_list_items').delete().eq('id', id);
  }

  // STORES
  Future<List<Store>> fetchStores() async {
    final res = await _client
        .from('stores')
        .select()
        .eq('user_id', _userId)
        .order('name', ascending: true);
    return (res as List).map((e) => Store.fromMap(e)).toList();
  }

  Future<Store> createStore(String name, {String? location}) async {
    final data = await _client
        .from('stores')
        .insert({
          'user_id': _userId,
          'name': name,
          'location': location,
        })
        .select()
        .single();
    return Store.fromMap(data);
  }

  Future<void> updateStore(String id, String name, {String? location}) async {
    await _client
        .from('stores')
        .update({
          'name': name,
          'location': location,
        })
        .eq('id', id);
  }

  Future<void> deleteStore(String id) async {
    await _client.from('stores').delete().eq('id', id);
  }

  // PURCHASES
  Future<List<Purchase>> fetchPurchases({int limit = 50}) async {
    final res = await _client
        .from('purchases')
        .select()
        .eq('user_id', _userId)
        .order('purchase_date', ascending: false)
        .limit(limit);
    return (res as List).map((e) => Purchase.fromMap(e)).toList();
  }

  Future<Purchase> createPurchase({
    String? listId,
    String? storeId,
    required String storeName,
    String? notes,
  }) async {
    final data = await _client
        .from('purchases')
        .insert({
          'user_id': _userId,
          'list_id': listId,
          'store_id': storeId,
          'store_name': storeName,
          'total_amount': 0.0,
          'currency': 'CRC',
          'notes': notes,
        })
        .select()
        .single();
    return Purchase.fromMap(data);
  }

  Future<void> deletePurchase(String id) async {
    await _client.from('purchases').delete().eq('id', id);
  }

  // PURCHASE ITEMS
  Future<List<PurchaseItem>> fetchPurchaseItems(String purchaseId) async {
    final res = await _client
        .from('purchase_items')
        .select()
        .eq('purchase_id', purchaseId)
        .order('created_at', ascending: true);
    return (res as List).map((e) => PurchaseItem.fromMap(e)).toList();
  }

  Future<PurchaseItem> addPurchaseItem({
    required String purchaseId,
    required String name,
    required int qty,
    required double unitPrice,
    String? category,
    String? notes,
  }) async {
    final totalPrice = qty * unitPrice;
    final data = await _client
        .from('purchase_items')
        .insert({
          'purchase_id': purchaseId,
          'name': name,
          'qty': qty,
          'unit_price': unitPrice,
          'total_price': totalPrice,
          'category': category,
          'notes': notes,
        })
        .select()
        .single();
    return PurchaseItem.fromMap(data);
  }

  Future<void> updatePurchaseItem({
    required String id,
    required String name,
    required int qty,
    required double unitPrice,
    String? category,
    String? notes,
  }) async {
    final totalPrice = qty * unitPrice;
    await _client
        .from('purchase_items')
        .update({
          'name': name,
          'qty': qty,
          'unit_price': unitPrice,
          'total_price': totalPrice,
          'category': category,
          'notes': notes,
        })
        .eq('id', id);
  }

  Future<void> deletePurchaseItem(String id) async {
    await _client.from('purchase_items').delete().eq('id', id);
  }

  // PRICE HISTORY & ANALYTICS
  Future<List<PriceHistory>> fetchPriceHistory(String itemName) async {
    final res = await _client
        .from('price_history')
        .select()
        .eq('user_id', _userId)
        .eq('item_name', itemName)
        .order('purchase_date', ascending: false)
        .limit(20);
    return (res as List).map((e) => PriceHistory.fromMap(e)).toList();
  }

  Future<Map<String, dynamic>> fetchSpendingByStore() async {
    final res = await _client
        .from('spending_by_store')
        .select()
        .eq('user_id', _userId);
    return {'stores': res};
  }

  Future<Map<String, dynamic>> fetchAveragePrices() async {
    final res = await _client
        .from('average_prices')
        .select()
        .eq('user_id', _userId);
    return {'items': res};
  }

  Future<Map<String, dynamic>> fetchMonthlySpending() async {
    final res = await _client
        .from('monthly_spending')
        .select()
        .eq('user_id', _userId);
    return {'months': res};
  }
}
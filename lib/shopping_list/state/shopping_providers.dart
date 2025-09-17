import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/shopping_data_source.dart';
import '../repo/shopping_repository.dart';
import '../model/shopping_list.dart';
import '../model/store_purchase_models.dart';

// Repository provider
final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepository(ShoppingDataSource());
});

// Shopping Lists providers
final shoppingListsProvider = StateNotifierProvider<ShoppingListsNotifier, AsyncValue<List<ShoppingList>>>((ref) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return ShoppingListsNotifier(repo)..loadLists();
});

final listItemsProvider = StateNotifierProvider.family<ListItemsNotifier, AsyncValue<List<ShoppingListItem>>, String>((ref, listId) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return ListItemsNotifier(repo, listId)..loadItems();
});

// Stores provider
final storesProvider = StateNotifierProvider<StoresNotifier, AsyncValue<List<Store>>>((ref) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return StoresNotifier(repo)..loadStores();
});

// Purchases provider
final purchasesProvider = StateNotifierProvider<PurchasesNotifier, AsyncValue<List<Purchase>>>((ref) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return PurchasesNotifier(repo)..loadPurchases();
});

// Purchase items provider
final purchaseItemsProvider = StateNotifierProvider.family<PurchaseItemsNotifier, AsyncValue<List<PurchaseItem>>, String>((ref, purchaseId) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return PurchaseItemsNotifier(repo, purchaseId)..loadItems();
});

// Analytics providers
final spendingByStoreProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return repo.getSpendingByStore();
});

final averagePricesProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return repo.getAveragePrices();
});

final monthlySpendingProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return repo.getMonthlySpending();
});

// Price history provider
final priceHistoryProvider = FutureProvider.family<List<PriceHistory>, String>((ref, itemName) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return repo.getPriceHistory(itemName);
});

// NOTIFIERS

class ShoppingListsNotifier extends StateNotifier<AsyncValue<List<ShoppingList>>> {
  final ShoppingRepository _repo;

  ShoppingListsNotifier(this._repo) : super(const AsyncLoading());

  Future<void> loadLists() async {
    state = const AsyncLoading();
    try {
      final lists = await _repo.getShoppingLists();
      state = AsyncData(lists);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> createList(String name, {String? description}) async {
    try {
      final newList = await _repo.createShoppingList(name, description: description);
      final currentLists = state.value ?? <ShoppingList>[];
      state = AsyncData([newList, ...currentLists]);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> updateList(String id, String name, {String? description}) async {
    try {
      await _repo.updateShoppingList(id, name, description: description);
      await loadLists(); // Reload to get updated data
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> deleteList(String id) async {
    try {
      await _repo.deleteShoppingList(id);
      final currentLists = state.value ?? <ShoppingList>[];
      final updatedLists = currentLists.where((list) => list.id != id).toList();
      state = AsyncData(updatedLists);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

class ListItemsNotifier extends StateNotifier<AsyncValue<List<ShoppingListItem>>> {
  final ShoppingRepository _repo;
  final String listId;

  ListItemsNotifier(this._repo, this.listId) : super(const AsyncLoading());

  Future<void> loadItems() async {
    state = const AsyncLoading();
    try {
      final items = await _repo.getListItems(listId);
      state = AsyncData(items);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> addItem(String name, int qty, {String? category}) async {
    try {
      final newItem = await _repo.addListItem(listId, name, qty, category: category);
      final currentItems = state.value ?? <ShoppingListItem>[];
      state = AsyncData([...currentItems, newItem]);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> updateItem(String id, String name, int qty, {String? category}) async {
    try {
      await _repo.updateListItem(id, name, qty, category: category);
      final currentItems = state.value ?? <ShoppingListItem>[];
      final updatedItems = currentItems.map((item) => 
        item.id == id 
          ? item.copyWith(name: name, qty: qty, category: category)
          : item
      ).toList();
      state = AsyncData(updatedItems);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _repo.deleteListItem(id);
      final currentItems = state.value ?? <ShoppingListItem>[];
      final updatedItems = currentItems.where((item) => item.id != id).toList();
      state = AsyncData(updatedItems);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

class StoresNotifier extends StateNotifier<AsyncValue<List<Store>>> {
  final ShoppingRepository _repo;

  StoresNotifier(this._repo) : super(const AsyncLoading());

  Future<void> loadStores() async {
    state = const AsyncLoading();
    try {
      final stores = await _repo.getStores();
      state = AsyncData(stores);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> createStore(String name, {String? location}) async {
    try {
      final newStore = await _repo.createStore(name, location: location);
      final currentStores = state.value ?? <Store>[];
      state = AsyncData([...currentStores, newStore]);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> updateStore(String id, String name, {String? location}) async {
    try {
      await _repo.updateStore(id, name, location: location);
      final currentStores = state.value ?? <Store>[];
      final updatedStores = currentStores.map((store) => 
        store.id == id 
          ? store.copyWith(name: name, location: location)
          : store
      ).toList();
      state = AsyncData(updatedStores);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> deleteStore(String id) async {
    try {
      await _repo.deleteStore(id);
      final currentStores = state.value ?? <Store>[];
      final updatedStores = currentStores.where((store) => store.id != id).toList();
      state = AsyncData(updatedStores);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

class PurchasesNotifier extends StateNotifier<AsyncValue<List<Purchase>>> {
  final ShoppingRepository _repo;

  PurchasesNotifier(this._repo) : super(const AsyncLoading());

  Future<void> loadPurchases({int limit = 50}) async {
    state = const AsyncLoading();
    try {
      final purchases = await _repo.getPurchases(limit: limit);
      state = AsyncData(purchases);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<Purchase?> createPurchase({
    String? listId,
    String? storeId,
    required String storeName,
    String? notes,
  }) async {
    try {
      final newPurchase = await _repo.createPurchase(
        listId: listId,
        storeId: storeId,
        storeName: storeName,
        notes: notes,
      );
      final currentPurchases = state.value ?? <Purchase>[];
      state = AsyncData([newPurchase, ...currentPurchases]);
      return newPurchase;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }

  Future<void> deletePurchase(String id) async {
    try {
      await _repo.deletePurchase(id);
      final currentPurchases = state.value ?? <Purchase>[];
      final updatedPurchases = currentPurchases.where((purchase) => purchase.id != id).toList();
      state = AsyncData(updatedPurchases);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

class PurchaseItemsNotifier extends StateNotifier<AsyncValue<List<PurchaseItem>>> {
  final ShoppingRepository _repo;
  final String purchaseId;

  PurchaseItemsNotifier(this._repo, this.purchaseId) : super(const AsyncLoading());

  Future<void> loadItems() async {
    state = const AsyncLoading();
    try {
      final items = await _repo.getPurchaseItems(purchaseId);
      state = AsyncData(items);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> addItem({
    required String name,
    required int qty,
    required double unitPrice,
    String? category,
    String? notes,
  }) async {
    try {
      final newItem = await _repo.addPurchaseItem(
        purchaseId: purchaseId,
        name: name,
        qty: qty,
        unitPrice: unitPrice,
        category: category,
        notes: notes,
      );
      final currentItems = state.value ?? <PurchaseItem>[];
      state = AsyncData([...currentItems, newItem]);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> updateItem({
    required String id,
    required String name,
    required int qty,
    required double unitPrice,
    String? category,
    String? notes,
  }) async {
    try {
      await _repo.updatePurchaseItem(
        id: id,
        name: name,
        qty: qty,
        unitPrice: unitPrice,
        category: category,
        notes: notes,
      );
      final currentItems = state.value ?? <PurchaseItem>[];
      final totalPrice = qty * unitPrice;
      final updatedItems = currentItems.map((item) => 
        item.id == id 
          ? item.copyWith(
              name: name, 
              qty: qty, 
              unitPrice: unitPrice,
              totalPrice: totalPrice,
              category: category,
              notes: notes
            )
          : item
      ).toList();
      state = AsyncData(updatedItems);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _repo.deletePurchaseItem(id);
      final currentItems = state.value ?? <PurchaseItem>[];
      final updatedItems = currentItems.where((item) => item.id != id).toList();
      state = AsyncData(updatedItems);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  double get totalAmount {
    final items = state.value ?? <PurchaseItem>[];
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/grocery_remote_ds.dart';
import '../repo/grocery_repository.dart';
import '../model/grocery_item.dart';

final repositoryProvider = Provider<GroceryRepository>((ref) {
  return GroceryRepository(GroceryRemoteDataSource());
});

final itemsProvider = StateNotifierProvider<ItemListNotifier, AsyncValue<List<GroceryItem>>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return ItemListNotifier(repo)..refresh();
});

class ItemListNotifier extends StateNotifier<AsyncValue<List<GroceryItem>>> {
  final GroceryRepository repo;
  ItemListNotifier(this.repo) : super(const AsyncLoading());

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final items = await repo.getItems();
      state = AsyncData(items);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> add(String name, int qty) async {
    try {
      final added = await repo.add(name, qty);
      final current = state.value ?? <GroceryItem>[];
      state = AsyncData([...current, added]);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> toggle(GroceryItem item) async {
    try {
      await repo.toggle(item);
      final list = <GroceryItem>[...(state.value ?? <GroceryItem>[])];
      final idx = list.indexWhere((e) => e.id == item.id);
      if (idx != -1) list[idx] = item.copyWith(done: !item.done);
      state = AsyncData(list);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> update(GroceryItem item) async {
    try {
      await repo.update(item);
      final list = <GroceryItem>[...(state.value ?? <GroceryItem>[])];
      final idx = list.indexWhere((e) => e.id == item.id);
      if (idx != -1) list[idx] = item;
      state = AsyncData(list);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> remove(String id) async {
    try {
      await repo.remove(id);
      final list = <GroceryItem>[...(state.value ?? <GroceryItem>[])];
      list.removeWhere((e) => e.id == id);
      state = AsyncData(list);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
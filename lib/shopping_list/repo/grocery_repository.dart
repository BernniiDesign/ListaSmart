import '../data/grocery_remote_ds.dart';
import '../model/grocery_item.dart';

class GroceryRepository {
  final GroceryRemoteDataSource ds;
  GroceryRepository(this.ds);

  Future<List<GroceryItem>> getItems() => ds.fetchItems();
  Future<GroceryItem> add(String name, int qty) => ds.addItem(name, qty);
  Future<void> toggle(GroceryItem item) => ds.toggleDone(item);
  Future<void> update(GroceryItem item) => ds.updateItem(item);
  Future<void> remove(String id) => ds.deleteItem(id);
}

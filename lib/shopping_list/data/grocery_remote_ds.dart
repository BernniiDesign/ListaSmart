import 'package:supabase_flutter/supabase_flutter.dart';
import '../../supabase/supabase_init.dart';
import '../model/grocery_item.dart';

class GroceryRemoteDataSource {
  static const table = 'shopping_items';

  final SupabaseClient _client;
  GroceryRemoteDataSource({SupabaseClient? client}) : _client = client ?? supabase;

  Future<List<GroceryItem>> fetchItems() async {
    final uid = _client.auth.currentUser!.id;
    final res = await _client
        .from(table)
        .select()
        .eq('user_id', uid)
        .order('inserted_at', ascending: true);
    return (res as List).map((e) => GroceryItem.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<GroceryItem> addItem(String name, int qty) async {
    final uid = _client.auth.currentUser!.id;
    final rows = await _client.from(table).insert({
      'user_id': uid,
      'name': name,
      'qty': qty,
      'done': false,
    }).select().limit(1);
    final map = (rows as List).first as Map<String, dynamic>;
    return GroceryItem.fromMap(map);
  }

  Future<void> toggleDone(GroceryItem item) async {
    await _client.from(table).update({'done': !item.done}).eq('id', item.id);
  }

  Future<void> updateItem(GroceryItem item) async {
    await _client.from(table).update({
      'name': item.name,
      'qty': item.qty,
    }).eq('id', item.id);
  }

  Future<void> deleteItem(String id) async {
    await _client.from(table).delete().eq('id', id);
  }
}

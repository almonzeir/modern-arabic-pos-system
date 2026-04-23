
import 'package:flutter/material.dart';
import '../models/pos_models.dart';
import '../services/db_helper.dart';

class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});
}

class POSProvider extends ChangeNotifier {
  List<MenuItem> _menuItems = [];
  final List<CartItem> _cart = [];
  final DBHelper _db = DBHelper();
  double _todayTotalSales = 0.0;

  List<MenuItem> get menuItems => _menuItems;
  List<CartItem> get cart => _cart;
  double get todayTotalSales => _todayTotalSales;

  double get totalAmount {
    return _cart.fold(0, (sum, item) => sum + (item.item.price * item.quantity));
  }

  int getItemQuantityInCart(int itemId) {
    int index = _cart.indexWhere((c) => c.item.id == itemId);
    return index != -1 ? _cart[index].quantity : 0;
  }

  Future<void> fetchMenu() async {
    _menuItems = await _db.getMenuItems();
    if (_menuItems.isEmpty) {
      // Sudanese Cafeteria Seed Data
      await addMenuItem('قهوة سوداء', 500.0, 'مشروبات');
      await addMenuItem('شاي سادة', 300.0, 'مشروبات');
      await addMenuItem('ساندوتش طعمية', 1200.0, 'طعام');
      await addMenuItem('بيرغر لحم', 2500.0, 'طعام');
      await addMenuItem('بسبوسة', 800.0, 'حلويات');
      _menuItems = await _db.getMenuItems();
    }
    await calculateTodaySales();
    notifyListeners();
  }

  Future<void> calculateTodaySales() async {
    final db = await _db.database;
    final String today = DateTime.now().toIso8601String().substring(0, 10);
    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT SUM(total_amount) as total FROM Orders WHERE timestamp LIKE '$today%'"
    );
    _todayTotalSales = (result.first['total'] as num?)?.toDouble() ?? 0.0;
    notifyListeners();
  }

  void addToCart(MenuItem item) {
    int index = _cart.indexWhere((c) => c.item.id == item.id);
    if (index != -1) {
      _cart[index].quantity++;
    } else {
      _cart.add(CartItem(item: item));
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void updateQuantity(CartItem cartItem, int newQty) {
    if (newQty <= 0) {
      _cart.remove(cartItem);
    } else {
      cartItem.quantity = newQty;
    }
    notifyListeners();
  }

  Future<void> completeOrder() async {
    if (_cart.isEmpty) return;
    
    final order = OrderModel(
      totalAmount: totalAmount,
      timestamp: DateTime.now(),
    );
    await _db.saveOrder(order);
    _cart.clear();
    await calculateTodaySales();
    notifyListeners();
  }

  Future<void> addMenuItem(String name, double price, String category) async {
    final item = MenuItem(name: name, price: price, category: category);
    await _db.insertMenuItem(item);
    await fetchMenu();
  }

  Future<void> deleteMenuItem(int id) async {
    await _db.deleteMenuItem(id);
    await fetchMenu();
  }
}

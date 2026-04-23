
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/pos_provider.dart';
import '../models/pos_models.dart';
import '../services/printing_service.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  String selectedCategory = 'الكل';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<POSProvider>();
    final categories = ['الكل', ...Set.from(pos.menuItems.map((e) => e.category))];
    
    final filteredItems = pos.menuItems.where((item) {
      final matchesCategory = selectedCategory == 'الكل' || item.category == selectedCategory;
      final matchesSearch = item.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Row(
      children: [
        // RIGHT: Cart Section
        Expanded(
          flex: 30,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Color(0xFFE0E6ED), width: 1.5)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('فاتورة جديدة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: pos.cart.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final cartItem = pos.cart[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(cartItem.item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)} جنيه'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => pos.updateQuantity(cartItem, cartItem.quantity - 1)),
                            Text('${cartItem.quantity}'),
                            IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => pos.updateQuantity(cartItem, cartItem.quantity + 1)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الإجمالي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('${pos.totalAmount.toStringAsFixed(2)} جنيه', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: pos.cart.isEmpty ? null : () async {
                      final cartCopy = List<CartItem>.from(pos.cart);
                      final totalCopy = pos.totalAmount;
                      await pos.completeOrder();
                      await PrintingService.printReceipt(cartCopy, totalCopy);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('دفع وطباعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // LEFT: Menu Grid
        Expanded(
          flex: 70,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'ابحث عن صنف...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => searchQuery = v),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final icon = _getIconForItem(item.category);
                      return InkWell(
                        onTap: () => pos.addToCart(item),
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(icon, size: 40, color: Colors.indigoAccent),
                              const SizedBox(height: 12),
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              Text('${item.price.toStringAsFixed(2)} جنيه', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForItem(String category) {
    switch (category) {
      case 'مشروبات': return FontAwesomeIcons.coffee;
      case 'طعام': return FontAwesomeIcons.hamburger;
      case 'مخبوزات': return FontAwesomeIcons.breadSlice;
      case 'حلويات': return FontAwesomeIcons.iceCream;
      default: return FontAwesomeIcons.utensils;
    }
  }
}

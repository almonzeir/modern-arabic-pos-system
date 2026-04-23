
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
        // RIGHT: Modern Cart Section (30%)
        Expanded(
          flex: 30,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(-5, 0),
                )
              ],
            ),
            child: Column(
              children: [
                // Cart Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.indigoAccent.withOpacity(0.05),
                    border: const Border(bottom: BorderSide(color: Color(0xFFF0F2F5))),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_basket_outlined, color: Colors.indigoAccent),
                      const SizedBox(width: 12),
                      const Text(
                        'قائمة الطلبات',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                      ),
                      const Spacer(),
                      if (pos.cart.isNotEmpty)
                        TextButton(
                          onPressed: () => pos.clearCart(),
                          child: const Text('مسح الكل', style: TextStyle(color: Colors.redAccent)),
                        ),
                    ],
                  ),
                ),
                
                // Cart Items List
                Expanded(
                  child: pos.cart.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('السلة فارغة حالياً', style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: pos.cart.length,
                          itemBuilder: (context, index) {
                            final cartItem = pos.cart[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFF0F2F5)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cartItem.item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text('${cartItem.item.price.toStringAsFixed(2)} جنيه', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F2F5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          icon: const Icon(Icons.remove, size: 18),
                                          onPressed: () => pos.updateQuantity(cartItem, cartItem.quantity - 1),
                                        ),
                                        Text('${cartItem.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          icon: const Icon(Icons.add, size: 18),
                                          onPressed: () => pos.updateQuantity(cartItem, cartItem.quantity + 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                
                // Checkout Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الإجمالي الكلي', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text('${pos.totalAmount.toStringAsFixed(2)} جنيه', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: pos.cart.isEmpty ? null : () async {
                            final cartCopy = List<CartItem>.from(pos.cart);
                            final totalCopy = pos.totalAmount;
                            final name = pos.cafeteriaName;
                            final title = pos.receiptTitle;
                            await pos.completeOrder();
                            await PrintingService.printReceipt(cartCopy, totalCopy, name, title);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.print_outlined),
                              SizedBox(width: 12),
                              Text('تأكيد وطباعة الإيصال', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // LEFT: Premium Menu Grid (70%)
        Expanded(
          flex: 70,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search and Title
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('كافتيريا الحي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                          Text('اختر الأصناف لتجهيز الطلب', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'ابحث عن صنف أو كود...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) => setState(() => searchQuery = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Horizontal Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (v) => setState(() => selectedCategory = cat),
                          selectedColor: Colors.indigoAccent,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Products Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final icon = _getIconForItem(item.category);
                      final color = _getColorForCategory(item.category);
                      
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => pos.addToCart(item),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.08),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    child: Center(
                                      child: FaIcon(icon, size: 48, color: color),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${item.price.toInt()} ج.س',
                                            style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.indigoAccent,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.add, color: Colors.white, size: 16),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
      case 'مشروبات': return FontAwesomeIcons.mugHot;
      case 'طعام': return FontAwesomeIcons.burger;
      case 'مخبوزات': return FontAwesomeIcons.breadSlice;
      case 'حلويات': return FontAwesomeIcons.iceCream;
      default: return FontAwesomeIcons.utensils;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'مشروبات': return Colors.brown;
      case 'طعام': return Colors.orange;
      case 'مخبوزات': return Colors.amber;
      case 'حلويات': return Colors.pink;
      default: return Colors.indigoAccent;
    }
  }
}

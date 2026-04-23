
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        // RIGHT: Cart Section (Pure Snow Clean)
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('فاتورة جديدة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
                      onPressed: pos.cart.isEmpty ? null : () => pos.clearCart(),
                      tooltip: 'تفريغ السلة',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: pos.cart.isEmpty 
                    ? const Center(child: Text('ابدأ بإضافة أصناف للطلب', style: TextStyle(color: Colors.grey, fontSize: 16)))
                    : ListView.separated(
                        itemCount: pos.cart.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final cartItem = pos.cart[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(cartItem.item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)} ريال', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _qtyBtn(Icons.remove, () => pos.updateQuantity(cartItem, cartItem.quantity - 1)),
                                    const SizedBox(width: 15),
                                    Text('${cartItem.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 15),
                                    _qtyBtn(Icons.add, () => pos.updateQuantity(cartItem, cartItem.quantity + 1)),
                                    const Spacer(),
                                    Text('${cartItem.item.price.toStringAsFixed(2)} للواحد', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الإجمالي اليومي', style: TextStyle(color: Colors.grey)),
                          Text('${pos.todayTotalSales.toStringAsFixed(2)} ريال', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الإجمالي الحالي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('${pos.totalAmount.toStringAsFixed(2)} ريال', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 65,
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
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('دفع وطباعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // LEFT: Menu Grid (Modern Paper White)
        Expanded(
          flex: 70,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE0E6ED)),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'ابحث عن صنف...',
                            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 18),
                          ),
                          onChanged: (v) => setState(() => searchQuery = v),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Modern Category Filter
                    SizedBox(
                      height: 55,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (v) => setState(() => selectedCategory = cat),
                              backgroundColor: Colors.white,
                              selectedColor: Colors.indigoAccent.withOpacity(0.1),
                              labelStyle: TextStyle(color: isSelected ? Colors.indigoAccent : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.indigoAccent : const Color(0xFFE0E6ED))),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final inCart = pos.getItemQuantityInCart(item.id!);
                      return _menuCard(item, inCart, () => pos.addToCart(item));
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

  Widget _qtyBtn(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E6ED)),
        ),
        child: Icon(icon, size: 18, color: Colors.indigoAccent),
      ),
    );
  }

  Widget _menuCard(MenuItem item, int qtyInCart, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: qtyInCart > 0 ? Colors.indigoAccent : const Color(0xFFE0E6ED), width: qtyInCart > 0 ? 2 : 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lunch_dining_rounded, color: Color(0xFF2D3436), size: 32),
                  const SizedBox(height: 12),
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D3436)), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('${item.price.toStringAsFixed(2)} ريال', style: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (qtyInCart > 0)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.indigoAccent, borderRadius: BorderRadius.circular(8)),
                  child: Text('$qtyInCart', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/pos_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController(text: 'طعام');

  Future<void> _checkUpdate() async {
    final url = Uri.parse('https://github.com/almonzeir/modern-arabic-pos-system/releases');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح رابط التحديث')),
        );
      }
    }
  }

  void _addItem() {
    final name = _nameController.text;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final category = _categoryController.text;

    if (name.isNotEmpty && price > 0) {
      context.read<POSProvider>().addMenuItem(name, price, category);
      _nameController.clear();
      _priceController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الصنف بنجاح!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<POSProvider>();

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RIGHT: Add Form
          Expanded(
            flex: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('إضافة صنف', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.sync), onPressed: _checkUpdate, tooltip: 'تحديث'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'اسم الصنف', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _priceController, 
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'السعر', border: OutlineInputBorder(), suffixText: 'ج.س')
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder())),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(onPressed: _addItem, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white), child: const Text('حفظ الصنف')),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
          // LEFT: Menu List
          Expanded(
            flex: 2,
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.all(24.0), child: Text('قائمة الأصناف الحالية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  Expanded(
                    child: ListView.separated(
                      itemCount: pos.menuItems.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = pos.menuItems[index];
                        return ListTile(
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item.category} • ${item.price.toStringAsFixed(2)} ج.س'),
                          trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => pos.deleteMenuItem(item.id!)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

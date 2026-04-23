
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController(text: 'عام');

  void _addItem() {
    final name = _nameController.text;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final category = _categoryController.text;

    if (name.isNotEmpty && price > 0) {
      context.read<POSProvider>().addMenuItem(name, price, category);
      _nameController.clear();
      _priceController.clear();
      _categoryController.text = 'عام';
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
          // اليمين: نموذج إضافة صنف
          Expanded(
            flex: 1,
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إضافة صنف جديد', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'اسم الصنف', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'السعر', 
                        border: OutlineInputBorder(), 
                        suffixText: 'ريال',
                        hintText: 'مثال: 15.50'
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _addItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('حفظ الصنف'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
          // اليسار: قائمة الأصناف
          Expanded(
            flex: 2,
            child: Card(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('قائمة الطعام الحالية', style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: pos.menuItems.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = pos.menuItems[index];
                        return ListTile(
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item.category} • ${item.price.toStringAsFixed(2)} ريال'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => pos.deleteMenuItem(item.id!),
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
      ),
    );
  }
}

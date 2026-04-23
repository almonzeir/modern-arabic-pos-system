
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
  
  final _cafeteriaNameController = TextEditingController();
  final _receiptTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final pos = context.read<POSProvider>();
    _cafeteriaNameController.text = pos.cafeteriaName;
    _receiptTitleController.text = pos.receiptTitle;
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إضافة الصنف بنجاح!'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _saveSettings() {
    context.read<POSProvider>().updateSettings(
      _cafeteriaNameController.text,
      _receiptTitleController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم حفظ الإعدادات بنجاح!'),
        backgroundColor: Colors.indigoAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<POSProvider>();

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إدارة المتجر', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                  Text('إضافة وتحرير الأصناف والأسعار', style: TextStyle(color: Colors.grey)),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _checkUpdate,
                icon: const Icon(Icons.system_update_alt_rounded),
                label: const Text('البحث عن تحديثات'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RIGHT: Form Sections
                Expanded(
                  flex: 35,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Settings Card
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('إعدادات الإيصال', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              _buildField('اسم الكافتيريا', _cafeteriaNameController, Icons.storefront),
                              const SizedBox(height: 20),
                              _buildField('عنوان الإيصال', _receiptTitleController, Icons.receipt_long),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _saveSettings,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.indigoAccent,
                                    elevation: 0,
                                    side: const BorderSide(color: Colors.indigoAccent),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: const Text('حفظ إعدادات الإيصال', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Add Item Card
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('إضافة صنف جديد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              _buildField('اسم الصنف', _nameController, Icons.label_important_outline),
                              const SizedBox(height: 20),
                              _buildField('السعر (جنيه)', _priceController, Icons.payments_outlined, isNumber: true),
                              const SizedBox(height: 20),
                              _buildField('التصنيف', _categoryController, Icons.category_outlined),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: _addItem,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigoAccent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: const Text('حفظ الصنف في النظام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                // LEFT: Inventory Table Section
                Expanded(
                  flex: 65,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('قائمة الأصناف المتوفرة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: pos.menuItems.length,
                            itemBuilder: (context, index) {
                              final item = pos.menuItems[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFF0F2F5)),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.indigoAccent.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.fastfood_outlined, color: Colors.indigoAccent),
                                  ),
                                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  subtitle: Text(item.category, style: TextStyle(color: Colors.grey[600])),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${item.price.toStringAsFixed(2)} ج.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigoAccent)),
                                      const SizedBox(width: 24),
                                      IconButton(
                                        icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                                        onPressed: () => _confirmDelete(item.id!),
                                      ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2D3436))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.indigoAccent, width: 2)),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا الصنف من القائمة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              context.read<POSProvider>().deleteMenuItem(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

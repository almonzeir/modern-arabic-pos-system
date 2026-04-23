
class MenuItem {
  final int? id;
  final String name;
  final double price;
  final String category;

  MenuItem({this.id, required this.name, required this.price, this.category = 'General'});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'price': price, 'category': category};
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      category: map['category'] ?? 'General',
    );
  }
}

class OrderModel {
  final int? id;
  final double totalAmount;
  final DateTime timestamp;
  final String status;

  OrderModel({this.id, required this.totalAmount, required this.timestamp, this.status = 'Completed'});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_amount': totalAmount,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }
}

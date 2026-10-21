class ShoppingItem {
  const ShoppingItem({
    this.id,
    required this.itemName,
    required this.category,
    required this.price,
    this.status = wishlist,
  });

  static const wishlist = 'Wishlist';
  static const purchased = 'Purchased';
  static const statuses = [wishlist, purchased];
  static const categories = ['Fashion', 'Electronics', 'Home', 'Other'];

  final int? id;
  final String itemName;
  final String category;
  final double price;
  final String status;

  bool get isWishlist => status == wishlist;

  ShoppingItem copyWith({int? id, String? status}) => ShoppingItem(
    id: id ?? this.id,
    itemName: itemName,
    category: category,
    price: price,
    status: status ?? this.status,
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'itemName': itemName,
    'category': category,
    'price': price,
    'status': status,
  };

  factory ShoppingItem.fromMap(Map<String, Object?> map) => ShoppingItem(
    id: map['id'] as int,
    itemName: map['itemName'] as String,
    category: map['category'] as String,
    price: (map['price'] as num).toDouble(),
    status: map['status'] as String,
  );
}

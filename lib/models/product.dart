/// Model: the product as the rest of the app understands it.
///
/// A model is plain data. It knows how to read itself from JSON and how to
/// write itself back, plus a few derived getters used by the views. It never
/// touches storage, services or the widget tree.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.iconName,
    this.description = '',
    this.originalPrice,
    this.stock = 0,
    this.isFeatured = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      iconName: json['icon'] as String,
      description: json['description'] as String? ?? '',
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isFeatured: json['featured'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final String iconName;
  final String description;

  /// Strike through price when the item is discounted.
  final double? originalPrice;

  /// Units left. `0` means out of stock.
  final int stock;

  final bool isFeatured;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'rating': rating,
      'icon': iconName,
      'description': description,
      'originalPrice': originalPrice,
      'stock': stock,
      'featured': isFeatured,
    };
  }

  String get priceLabel => formatPrice(price);

  String get originalPriceLabel =>
      originalPrice == null ? '' : formatPrice(originalPrice!);

  bool get isOnSale => originalPrice != null && originalPrice! > price;

  bool get inStock => stock > 0;

  bool get isLowStock => stock > 0 && stock <= 3;

  String get stockLabel {
    if (!inStock) return 'Out of stock';
    if (isLowStock) return 'Only $stock left';
    return 'In stock';
  }

  /// How much the customer saves, in percent.
  int get discountPercent {
    final double? was = originalPrice;
    if (was == null || was <= price) return 0;
    return (((was - price) / was) * 100).round();
  }

  String get ratingLabel => rating.toStringAsFixed(1);

  static String formatPrice(double value) => '\$${value.toStringAsFixed(2)}';
}
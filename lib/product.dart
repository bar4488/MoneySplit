import 'dart:convert';

class Product {
  double price;
  String name;
  int amount;

  double get totalPrice => price * amount;

  Product({
    this.price,
    this.name,
    this.amount,
  });

  Product copyWith({
    double price,
    String name,
    int amount,
  }) {
    return Product(
      price: price ?? this.price,
      name: name ?? this.name,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'name': name,
      'amount': amount,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Product(
      price: map['price'],
      name: map['name'],
      amount: map['amount'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));

  @override
  String toString() => 'Product(price: $price, name: $name, amount: $amount)';
}

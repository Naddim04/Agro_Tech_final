import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_service.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  factory CartItem.fromMap(Map<String, dynamic> map, Product product) {
    return CartItem(
      id: map['id'],
      product: product,
      quantity: map['quantity'] as int,
    );
  }
}

class CartService {
  final _supabase = Supabase.instance.client;

  /// Fetch all cart items for the current user
  Future<List<CartItem>> fetchCartItems() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', userId);

    return (response as List).map((item) {
      final productMap = item['products'] as Map<String, dynamic>;
      final product = Product.fromMap(productMap);
      return CartItem.fromMap(item, product);
    }).toList();
  }

  /// Add product to cart
  Future<void> addToCart(Product product) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    // Check if item already exists in cart
    final existingItems = await _supabase
        .from('cart_items')
        .select()
        .eq('user_id', userId)
        .eq('product_id', product.id);

    if ((existingItems as List).isNotEmpty) {
      // Update quantity
      final existingItem = existingItems[0];
      await _supabase.from('cart_items').update({
        'quantity': (existingItem['quantity'] as int) + 1,
      }).eq('id', existingItem['id']);
    } else {
      // Insert new item
      await _supabase.from('cart_items').insert({
        'user_id': userId,
        'product_id': product.id,
        'quantity': 1,
      });
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    await _supabase.from('cart_items').delete().eq('id', cartItemId);
  }

  /// Update item quantity
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(cartItemId);
    } else {
      await _supabase
          .from('cart_items')
          .update({'quantity': newQuantity}).eq('id', cartItemId);
    }
  }
}

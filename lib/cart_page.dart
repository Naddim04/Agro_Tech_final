import 'package:flutter/material.dart';
import 'services/cart_service.dart';
import 'widgets/top_header.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _cartService = CartService();
  bool _isLoading = true;
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    try {
      final items = await _cartService.fetchCartItems();
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cart: $e')),
        );
      }
    }
  }

  double get _totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const TopHeader(title: 'My Cart'),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
                    : _cartItems.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              return _buildCartItemCard(_cartItems[index]);
                            },
                          ),
              ),
              if (_cartItems.isNotEmpty) _buildCheckoutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.black.withOpacity(0.05)),
          const SizedBox(height: 16),
          const Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.black38, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Go shop for some fresh crops!'),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item.product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.image)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('৳${item.product.price} / unit', style: const TextStyle(color: Colors.black38, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('৳${item.product.price * item.quantity}', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        _buildQuantityBtn(Icons.remove, () => _updateQuantity(item, -1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        _buildQuantityBtn(Icons.add, () => _updateQuantity(item, 1)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Color(0xFF455A64)),
      ),
    );
  }

  Future<void> _updateQuantity(CartItem item, int delta) async {
    final newQty = item.quantity + delta;
    await _cartService.updateQuantity(item.id, newQty);
    _loadCart();
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(color: Colors.black38, fontSize: 16)),
              Text('৳${_totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF455A64))),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Future implementation: Checkout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Checkout Now', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

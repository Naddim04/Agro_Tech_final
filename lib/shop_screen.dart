import 'package:flutter/material.dart';
import 'widgets/top_header.dart';
import 'services/product_service.dart';
import 'services/cart_service.dart';
import 'cart_page.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _productService = ProductService();
  final _cartService = CartService();

  String _activeTab = 'All Products';
  bool _isLoading = true;
  List<Product> _products = [];

  // ✅ NEW
  String _searchQuery = '';
  bool _showHighRatedOnly = false;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      List<Product> products;

      if (_activeTab == 'All Products') {
        products = await _productService.fetchProducts();
      } else {
        products = await _productService.fetchMyProducts();
      }

      // 🔍 Search filter
      if (_searchQuery.isNotEmpty) {
        products = products.where((p) =>
            p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      }

      // ⭐ Rating filter
      if (_showHighRatedOnly) {
        products = products.where((p) => p.rating >= 4).toList();
      }

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading shop: $e')),
        );
      }
    }
  }

  Future<void> _addToCart(Product product) async {
    try {
      await _cartService.addToCart(product);

      setState(() {
        _cartCount++;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const CartPage()));
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Cart Error: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            TopHeader(
              title: 'Shop',
              showBackButton: false,
              actions: [
                // 🛒 Cart with badge
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CartPage()));
                      },
                      icon: const Icon(Icons.shopping_bag_outlined,
                          color: Color(0xFF455A64)),
                    ),
                    if (_cartCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$_cartCount',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                        ),
                      )
                  ],
                ),
              ],
            ),

            // 🔍 Search + Filter
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          _searchQuery = value;
                          _loadProducts();
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search,
                              color: Colors.orangeAccent),
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ⭐ Filter Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showHighRatedOnly = !_showHighRatedOnly;
                      });
                      _loadProducts();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _showHighRatedOnly
                            ? Colors.orangeAccent
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.filter_list,
                        color: _showHighRatedOnly
                            ? Colors.white
                            : Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  _buildTab('All Products'),
                  const SizedBox(width: 24),
                  _buildTab('My Listing'),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProducts,
                color: Colors.orangeAccent,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Colors.orangeAccent))
                    : _products.isEmpty
                        ? _buildEmptyState()
                        : GridView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              return _buildProductCard(
                                  _products[index]);
                            },
                          ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 64, color: Colors.black12),
              SizedBox(height: 16),
              Text(
                'No products found',
                style: TextStyle(
                    color: Colors.black26,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label) {
    bool active = _activeTab == label;
    return GestureDetector(
      onTap: () {
        setState(() => _activeTab = label);
        _loadProducts();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color:
                  active ? const Color(0xFF455A64) : Colors.black26,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (active)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 30,
              color: const Color(0xFF455A64),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 15)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image,
                      color: Colors.grey, size: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: Colors.orangeAccent, size: 14),
                    const SizedBox(width: 4),
                    Text('${product.rating}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(product.location,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black26)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('View Details',
                        style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 12,
                            decoration:
                                TextDecoration.underline)),
                    GestureDetector(
                      onTap: () => _addToCart(product),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.orangeAccent
                                .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(8)),
                        child: const Icon(
                            Icons.shopping_basket_outlined,
                            color: Colors.orangeAccent,
                            size: 18),
                      ),
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
}

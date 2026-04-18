import 'package:flutter/material.dart';
import 'services/product_service.dart';
import 'add_product_page.dart';
import 'widgets/top_header.dart';

class MyCropsPage extends StatefulWidget {
  const MyCropsPage({super.key});

  @override
  State<MyCropsPage> createState() => _MyCropsPageState();
}

class _MyCropsPageState extends State<MyCropsPage> {
  final _productService = ProductService();
  bool _isLoading = true;
  List<Product> _myProducts = [];

  @override
  void initState() {
    super.initState();
    _loadMyProducts();
  }

  Future<void> _loadMyProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productService.fetchMyProducts();
      setState(() {
        _myProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading crops: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
          if (result == true) {
            _loadMyProducts(); // Refresh list if product was added
          }
        },
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
              const TopHeader(title: 'My Crops'),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
                    : _myProducts.isEmpty
                        ? _buildEmptyState()
                        : GridView.builder(
                            padding: const EdgeInsets.all(24),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _myProducts.length,
                            itemBuilder: (context, index) {
                              return _buildCropCard(_myProducts[index]);
                            },
                          ),
              ),
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
          Icon(Icons.grass, size: 80, color: Colors.black.withOpacity(0.05)),
          const SizedBox(height: 16),
          const Text(
            'No crops listed yet',
            style: TextStyle(fontSize: 18, color: Colors.black38, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Tap the + button to add your first crop!'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              setState(() => _isLoading = true);
              await _productService.seedMockData();
              _loadMyProducts();
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Seed Mock Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              foregroundColor: Colors.blueAccent,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                // Action Buttons
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      _buildActionCircle(
                        Icons.edit,
                        Colors.blueAccent,
                        () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddProductPage(product: product)),
                          );
                          if (result == true) _loadMyProducts();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionCircle(
                        Icons.delete_outline,
                        Colors.redAccent,
                        () => _showDeleteConfirm(product),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '৳${product.price}',
                  style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: const TextStyle(fontSize: 11, color: Colors.black26),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCircle(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  void _showDeleteConfirm(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Crop?'),
        content: Text('Are you sure you want to remove "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black38)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              setState(() => _isLoading = true);
              try {
                await _productService.deleteProduct(product.id, product.imageUrl);
                _loadMyProducts();
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

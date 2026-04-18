import 'package:flutter/material.dart';
import '../services/product_service.dart';

class MarketViewSection extends StatefulWidget {
  const MarketViewSection({super.key});

  @override
  State<MarketViewSection> createState() => _MarketViewSectionState();
}

class _MarketViewSectionState extends State<MarketViewSection> {
  final _productService = ProductService();
  bool _isLoading = true;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadMarketData();
  }

  Future<void> _loadMarketData() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productService.fetchProducts();
      setState(() {
        _products = products.take(6).toList(); // Show top 6 for the home screen
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Market View',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF455A64),
                ),
              ),
              TextButton(
                onPressed: _loadMarketData,
                child: Text(_isLoading ? 'Updating...' : 'See More', style: const TextStyle(color: Colors.black38, fontSize: 13)),
              ),
            ],
          ),
        ),
        if (_isLoading)
          const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: Colors.orangeAccent)))
        else if (_products.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Text('No market data available', style: TextStyle(color: Colors.black26)),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    children: _buildColumnItems(0),
                  ),
                ),
                const SizedBox(width: 12),
                // Right Column
                Expanded(
                  child: Column(
                    children: _buildColumnItems(1),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _buildColumnItems(int remainder) {
    List<Widget> items = [];
    for (int i = 0; i < _products.length; i++) {
      if (i % 2 == remainder) {
        items.add(_buildMarketCard(
          product: _products[i],
          isLarge: i == 0 || i == 5, // Just to keep the asymmetric design
        ));
        items.add(const SizedBox(height: 12));
      }
    }
    return items;
  }

  Widget _buildMarketCard({
    required Product product,
    required bool isLarge,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: isLarge ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF455A64),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_upward, color: Colors.orangeAccent, size: 12),
                  ],
                ),
                if (isLarge) const SizedBox(height: 24) else const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '৳${product.price.round()}',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_upward, color: Colors.orangeAccent, size: 10),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.location,
                  style: const TextStyle(color: Colors.black26, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.imageUrl,
              width: isLarge ? 50 : 40,
              height: isLarge ? 75 : 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: isLarge ? 50 : 40,
                height: isLarge ? 75 : 40,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 20, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

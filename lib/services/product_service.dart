import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String location;
  final String category;
  final String ownerId;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.location,
    required this.category,
    required this.ownerId,
    this.rating = 4.9,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'],
      location: map['location'] ?? 'Savar, Dhaka',
      category: map['category'] ?? 'General',
      ownerId: map['owner_id']?.toString() ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
    );
  }
}

class ProductService {
  final _supabase = Supabase.instance.client;

  /// Fetch all products for the shop
  Future<List<Product>> fetchProducts({String? category}) async {
    var query = _supabase.from('products').select();
    
    if (category != null && category != 'All') {
      query = query.eq('category', category);
    }
    
    final response = await query.order('created_at', ascending: false);
    return (response as List).map((p) => Product.fromMap(p)).toList();
  }

  /// Fetch products owned by the current user
  Future<List<Product>> fetchMyProducts() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('products')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false);
        
    return (response as List).map((p) => Product.fromMap(p)).toList();
  }

  /// Upload image to Supabase Storage
  Future<String> uploadProductImage(File imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
    final String pathInBucket = 'products/$fileName';

    await _supabase.storage.from('product-images').upload(
          pathInBucket,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return _supabase.storage.from('product-images').getPublicUrl(pathInBucket);
  }

  /// Add a new product
  Future<void> addProduct({
    required String name,
    required double price,
    required String imageUrl,
    required String category,
    required String location,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _supabase.from('products').insert({
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'location': location,
      'owner_id': userId,
    });
  }

  /// Delete a product and its image
  Future<void> deleteProduct(String productId, String imageUrl) async {
    // 1. Delete from database
    await _supabase.from('products').delete().eq('id', productId);

    // 2. Try to delete from storage if it's a Supabase URL
    try {
      if (imageUrl.contains('product-images')) {
        final uri = Uri.parse(imageUrl);
        final pathInBucket = uri.pathSegments.sublist(uri.pathSegments.indexOf('product-images') + 1).join('/');
        await _supabase.storage.from('product-images').remove([pathInBucket]);
      }
    } catch (e) {
      // Ignore storage errors to ensure the database stays clean
      print('Storage delete error: $e');
    }
  }

  /// Update an existing product
  Future<void> updateProduct({
    required String id,
    required String name,
    required double price,
    required String imageUrl,
    required String category,
    required String location,
  }) async {
    await _supabase.from('products').update({
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'location': location,
    }).eq('id', id);
  }

  /// One-time setup for mock data (Can be called from a hidden debug button or on first run)
  Future<void> seedMockData() async {
    final products = [
      {'name': 'Potato', 'price': 20.0, 'category': 'Vegetable', 'image_url': 'https://picsum.photos/seed/potato/400/300'},
      {'name': 'Tomato', 'price': 45.0, 'category': 'Vegetable', 'image_url': 'https://picsum.photos/seed/tomato/400/300'},
      {'name': 'Rice (BR28)', 'price': 65.0, 'category': 'Grain', 'image_url': 'https://picsum.photos/seed/rice/400/300'},
      {'name': 'Wheat Seeds', 'price': 120.0, 'category': 'Seeds', 'image_url': 'https://picsum.photos/seed/wheat/400/300'},
      {'name': 'Organic Urea', 'price': 800.0, 'category': 'Fertilizer', 'image_url': 'https://picsum.photos/seed/fertilizer/400/300'},
      {'name': 'Mango (Amrapali)', 'price': 150.0, 'category': 'Fruit', 'image_url': 'https://picsum.photos/seed/mango/400/300'},
    ];

    for (var p in products) {
      await _supabase.from('products').insert(p);
    }
  }
}

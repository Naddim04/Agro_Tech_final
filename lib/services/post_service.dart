import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class Post {
  final String id;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final String content;
  final String? imageUrl;
  final String? location;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.content,
    this.imageUrl,
    this.location,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'].toString(),
      userId: map['user_id']?.toString() ?? '',
      userName: map['user_name'],
      userAvatar: map['user_avatar'],
      content: map['content'] ?? '',
      imageUrl: map['image_url'],
      location: map['location'],
      createdAt: DateTime.parse(map['created_at'].toString()),
    );
  }
}

class PostService {
  final _supabase = Supabase.instance.client;

  /// Fetch all posts for the global feed
  Future<List<Post>> fetchPosts() async {
    final response = await _supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((p) => Post.fromMap(p)).toList();
  }

  /// Fetch posts owned by the current user for "My Farm"
  Future<List<Post>> fetchMyPosts() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('posts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
        
    return (response as List).map((p) => Post.fromMap(p)).toList();
  }

  /// Upload post image to Supabase Storage
  Future<String> uploadPostImage(File imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
    final String pathInBucket = 'posts/$fileName';

    await _supabase.storage.from('post-images').upload(
          pathInBucket,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return _supabase.storage.from('post-images').getPublicUrl(pathInBucket);
  }

  /// Add a new post
  Future<void> addPost({
    required String content,
    String? imageUrl,
    String? location,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final name = user.userMetadata?['full_name'];
    final avatar = user.userMetadata?['avatar_url'];

    await _supabase.from('posts').insert({
      'user_id': user.id,
      'user_name': name,
      'user_avatar': avatar,
      'content': content,
      'image_url': imageUrl,
      'location': location,
    });
  }

  /// Delete a post and its associated image
  Future<void> deletePost(String postId, String? imageUrl) async {
    // 1. Delete from database
    await _supabase.from('posts').delete().eq('id', postId);

    // 2. Delete from storage if applicable
    if (imageUrl != null && imageUrl.contains('post-images')) {
      try {
        final uri = Uri.parse(imageUrl);
        final pathInBucket = uri.pathSegments.sublist(uri.pathSegments.indexOf('post-images') + 1).join('/');
        await _supabase.storage.from('post-images').remove([pathInBucket]);
      } catch (e) {
        print('Error deleting post image: $e');
      }
    }
  }
}

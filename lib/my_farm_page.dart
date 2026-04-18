import 'package:flutter/material.dart';
import 'services/post_service.dart';
import 'widgets/top_header.dart';
import 'add_post_page.dart';
import 'package:intl/intl.dart';

class MyFarmPage extends StatefulWidget {
  const MyFarmPage({super.key});

  @override
  State<MyFarmPage> createState() => _MyFarmPageState();
}

class _MyFarmPageState extends State<MyFarmPage> {
  final _postService = PostService();
  bool _isLoading = true;
  List<Post> _myPosts = [];

  @override
  void initState() {
    super.initState();
    _loadMyPosts();
  }

  Future<void> _loadMyPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _postService.fetchMyPosts();
      setState(() {
        _myPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading posts: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePost(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this farm update?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _postService.deletePost(post.id, post.imageUrl);
        _loadMyPosts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting post: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const TopHeader(title: 'My Farm', showBackButton: true),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : _myPosts.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadMyPosts,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: _myPosts.length,
                            itemBuilder: (context, index) {
                              return _buildPostCard(_myPosts[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostPage()),
          );
          if (result == true) {
            _loadMyPosts();
          }
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text('Add Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.agriculture_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No farm updates yet', style: TextStyle(color: Colors.black38, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Tap "Add Update" to share your progress!', style: TextStyle(color: Colors.black26)),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(post.createdAt),
                style: const TextStyle(color: Colors.black38, fontSize: 12),
              ),
              IconButton(
                onPressed: () => _deletePost(post),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (post.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            post.content,
            style: const TextStyle(color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}

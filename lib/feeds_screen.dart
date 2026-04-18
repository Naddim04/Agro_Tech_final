import 'package:flutter/material.dart';
import 'widgets/top_header.dart';
import 'widgets/category_section.dart';
import 'services/post_service.dart';
import 'package:intl/intl.dart';
import 'widgets/post_detail_dialog.dart';

class FeedsScreen extends StatefulWidget {
  const FeedsScreen({super.key});

  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  final _postService = PostService();

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
            const TopHeader(title: 'Feeds'),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.orangeAccent),
                    hintText: 'Search',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: FutureBuilder<List<Post>>(
                  future: _postService.fetchPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final posts = snapshot.data ?? [];
                    
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const CategorySection(),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Row(
                              children: [
                                _FeedTab(label: 'Posts', active: true),
                                SizedBox(width: 12),
                                _FeedTab(label: 'Videos'),
                                SizedBox(width: 12),
                                _FeedTab(label: 'Community'),
                              ],
                            ),
                          ),
                          if (posts.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Text('No posts yet. Be the first to post!', style: TextStyle(color: Colors.black38)),
                              ),
                            )
                          else
                            ...posts.map((post) => _buildFeedItem(post)),
                          const SizedBox(height: 100),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedItem(Post post) {
    return GestureDetector(
      onTap: () => PostDetailDialog.show(context, post),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: post.userAvatar != null 
                      ? NetworkImage(post.userAvatar!) 
                      : const NetworkImage('https://i.pravatar.cc/150?img=12'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      '${post.location ?? "Unknown Location"} • ${DateFormat('dd MMM, yyyy').format(post.createdAt)}',
                      style: const TextStyle(color: Colors.black38, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (post.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  post.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey, size: 50),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.favorite_border, color: Colors.black45),
                    SizedBox(width: 20),
                    Icon(Icons.chat_bubble_outline, color: Colors.black45),
                    SizedBox(width: 20),
                    Icon(Icons.bookmark_border, color: Colors.black45),
                  ],
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined, color: Colors.black45)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  final String label;
  final bool active;
  const _FeedTab({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: active ? Colors.orangeAccent : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [if (!active) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Text(
        label,
        style: TextStyle(color: active ? Colors.white : Colors.black45, fontWeight: FontWeight.bold),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/post_service.dart';
import 'post_detail_dialog.dart';

class AgriArticlesSection extends StatelessWidget {
  final Function(Post)? onPostTap;
  const AgriArticlesSection({super.key, this.onPostTap});

  @override
  Widget build(BuildContext context) {
    final postService = PostService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Agri Articles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF455A64),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See More', style: TextStyle(color: Colors.black38, fontSize: 13)),
              ),
            ],
          ),
        ),
        FutureBuilder<List<Post>>(
          future: postService.fetchPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator(color: Colors.orangeAccent)),
              );
            }
            
            final allPosts = snapshot.data ?? [];
            final posts = allPosts.take(5).toList();

            if (posts.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(child: Text('No articles yet', style: TextStyle(color: Colors.black26))),
              );
            }

            return SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 24),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return GestureDetector(
                    onTap: () {
                      if (onPostTap != null) onPostTap!(post);
                      PostDetailDialog.show(context, post);
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: post.imageUrl != null
                                  ? Image.network(post.imageUrl!, fit: BoxFit.cover, width: double.infinity)
                                  : Container(
                                      width: double.infinity,
                                      color: Colors.grey[100],
                                      child: const Icon(Icons.article_outlined, color: Colors.grey),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              post.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, height: 1.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

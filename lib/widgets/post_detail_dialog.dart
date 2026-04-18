import 'package:flutter/material.dart';
import '../services/post_service.dart';
import 'package:intl/intl.dart';

class PostDetailDialog extends StatelessWidget {
  final Post post;

  const PostDetailDialog({super.key, required this.post});

  static void show(BuildContext context, Post post) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PostDetailDialog(post: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: post.userAvatar != null
                        ? NetworkImage(post.userAvatar!)
                        : const NetworkImage('https://i.pravatar.cc/150?img=12'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${post.location ?? "Unknown Location"} • ${DateFormat('dd MMM, yyyy').format(post.createdAt)}',
                          style: const TextStyle(color: Colors.black38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black45),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Image
              if (post.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    post.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              // Interaction Bar
              Row(
                children: [
                  const Icon(Icons.favorite_border, color: Colors.black45),
                  const SizedBox(width: 20),
                  const Icon(Icons.chat_bubble_outline, color: Colors.black45),
                  const SizedBox(width: 20),
                  const Icon(Icons.bookmark_border, color: Colors.black45),
                  const Spacer(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined, color: Colors.black45)),
                ],
              ),
              const Divider(height: 24),
              
              // Full Content
              Text(
                post.content,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

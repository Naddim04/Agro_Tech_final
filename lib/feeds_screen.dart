import 'package:flutter/material.dart';

class Post {
  final String content;
  bool isLiked;

  Post({required this.content, this.isLiked = false});
}

class FeedsScreen extends StatefulWidget {
  const FeedsScreen({super.key});

  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  String _searchQuery = '';

  Future<List<Post>> fetchPosts() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Post(content: "This is my first post! Flutter is awesome 🚀"),
      Post(content: "Exploring new UI designs today."),
      Post(content: "Machine Learning project going well!"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feeds"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Colors.orangeAccent),
                hintText: 'Search posts...',
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: fetchPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData) {
                  _allPosts = snapshot.data!;
                  _filteredPosts = _allPosts.where((post) {
                    return post.content
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
                  }).toList();
                }

                if (_filteredPosts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hourglass_empty,
                              size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            'No posts found',
                            style: TextStyle(color: Colors.black38),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {});
                  },
                  child: ListView.builder(
                    itemCount: _filteredPosts.length,
                    itemBuilder: (context, index) {
                      return _buildFeedItem(_filteredPosts[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedItem(Post post) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpandableText(post.content),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : Colors.black45,
                  ),
                  onPressed: () {
                    setState(() {
                      post.isLiked = !post.isLiked;
                    });
                  },
                ),
                const SizedBox(width: 10),
                const Icon(Icons.chat_bubble_outline,
                    color: Colors.black45),
                const SizedBox(width: 20),
                const Icon(Icons.bookmark_border,
                    color: Colors.black45),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText(this.text, {super.key});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: expanded ? null : 3,
          overflow: expanded
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black87),
        ),
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Text(
            expanded ? "Show less" : "Read more",
            style: const TextStyle(color: Colors.orangeAccent),
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  final List<Map<String, String>> categories = const [
    {'name': 'Plant', 'img': 'https://cdn-icons-png.flaticon.com/512/628/628283.png'},
    {'name': 'Potato', 'img': 'https://cdn-icons-png.flaticon.com/512/3592/3592120.png'},
    {'name': 'Tomato', 'img': 'https://cdn-icons-png.flaticon.com/512/1202/1202125.png'},
    {'name': 'Mango', 'img': 'https://cdn-icons-png.flaticon.com/512/1531/1531317.png'},
    {'name': 'Pumpkin', 'img': 'https://cdn-icons-png.flaticon.com/512/604/604104.png'},
  ];

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
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF455A64),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Add More', style: TextStyle(color: Colors.black38, fontSize: 13)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.network(
                        categories[index]['img']!,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, color: Colors.orangeAccent, size: 30),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      categories[index]['name']!,
                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

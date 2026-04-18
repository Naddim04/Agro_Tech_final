import 'package:flutter/material.dart';

class AgriServicesSection extends StatelessWidget {
  const AgriServicesSection({super.key});

  final List<Map<String, String>> services = const [
    {'name': 'Soil Test', 'img': 'https://picsum.photos/seed/soil/300/300'},
    {'name': 'Farm Labour', 'img': 'https://picsum.photos/seed/worker/300/300'},
    {'name': 'Advisory', 'img': 'https://picsum.photos/seed/advisor/300/300'},
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
                'Agri Services',
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
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return Container(
                width: 130,
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
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(services[index]['img']!, fit: BoxFit.cover, width: double.infinity),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        services[index]['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
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

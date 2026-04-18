import 'package:flutter/material.dart';
import 'widgets/header_widget.dart';
import 'widgets/category_section.dart';
import 'widgets/banner_card.dart';
import 'widgets/weather_section.dart';
import 'widgets/market_view_section.dart';
import 'widgets/agri_articles_section.dart';
import 'feeds_screen.dart';
import 'shop_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeTab(onSwitchTab: (index) => setState(() => _selectedIndex = index)),
      const FeedsScreen(),
      const ShopScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
          _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 'Feeds', 1),
          _buildNavItem(Icons.shopping_cart_outlined, Icons.shopping_cart, 'Shop', 2),
          _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData outline, IconData solid, String label, int index) {
    bool selected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected ? Colors.orangeAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              selected ? solid : outline,
              color: selected ? Colors.white : Colors.black38,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.orangeAccent : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final Function(int)? onSwitchTab;
  const HomeTab({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3F2FD),
            Color(0xFFF5F5F5),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderWidget(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.orangeAccent),
                      hintText: 'Search',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black26),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const CategorySection(),
              const BannerCard(),
              const WeatherSection(),
              const SizedBox(height: 16),
              const MarketViewSection(),
              const SizedBox(height: 16),
              AgriArticlesSection(onPostTap: (post) {
                if (onSwitchTab != null) {
                  onSwitchTab!(1); // Switch to Feeds tab
                }
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

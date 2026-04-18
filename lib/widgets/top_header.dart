import 'package:flutter/material.dart';

class TopHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? trailing;
  final VoidCallback? onBack;

  const TopHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (showBackButton) const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF455A64),
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (actions != null) ...actions!,
              if (trailing != null) trailing!,
              const SizedBox(width: 12),
              // Language Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildLangButton('BN', false),
                    _buildLangButton('EN', true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? Colors.orangeAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.black45,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

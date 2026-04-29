import 'package:flutter/material.dart';

class ShimmerList extends StatefulWidget {
  const ShimmerList({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  State<ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<ShimmerList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final highlightColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.itemCount,
      itemBuilder: (_, index) => AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment(_animation.value - 1, 0),
                end: Alignment(_animation.value + 1, 0),
                colors: [baseColor, highlightColor, baseColor],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 160, color: Colors.transparent),
                const SizedBox(height: 8),
                Container(height: 12, width: double.infinity, color: Colors.transparent),
                const SizedBox(height: 4),
                Container(height: 12, width: 120, color: Colors.transparent),
              ],
            ),
          );
        },
      ),
    );
  }
}

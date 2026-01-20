import 'dart:ui';
import 'package:flutter/material.dart';

class AdvancedBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdvancedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30), // Highly rounded corners
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 70, // Slightly shorter for a more compact look
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.85),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color.fromARGB(
                  255,
                  214,
                  209,
                  209,
                ).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.access_time_filled_rounded,
                  label: 'Recents',
                  index: 2,
                  isSelected: currentIndex == 2,
                  onTap: onTap,
                ),
                _NavItem(
                  icon: Icons.account_circle_rounded,
                  label: 'Contacts',
                  index: 0,
                  isSelected: currentIndex == 0,
                  onTap: onTap,
                ),
                _NavItem(
                  icon: Icons.dialpad_sharp,
                  label: 'Keypad',
                  index: 1,
                  isSelected: currentIndex == 1,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Premium Blue vs Muted Gray
    final activeColor = const Color(0xFF007AFF);
    final inactiveColor = Colors.grey.shade400;
    final color = widget.isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () => widget.onTap(widget.index),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Smaller Icon (22px)
            Icon(widget.icon, color: color, size: 22),
            const SizedBox(height: 4),
            // Very Small, Elegant Text (10px)
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: widget.isSelected
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            // Unique Indicator Dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              width: widget.isSelected ? 4 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

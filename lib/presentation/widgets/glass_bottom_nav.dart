import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onFabTap;
  final VoidCallback onFabLongPress;

  const GlassBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
    required this.onFabLongPress,
  }) : super(key: key);

  @override
  State<GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends State<GlassBottomNav> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _glowAnimation;

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.bar_chart_rounded,
    Icons.medication_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = [
    "الرئيسية",
    "التقارير",
    "تنبيهاتي",
    "حسابي",
  ];

  @override
  void initState() {
    super.initState();
    // Breathing animation for the center FAB glow
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 4.0, end: 15.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We calculate the width of each tab to position the sliding indicator
    // Total 5 slots: 2 on right, 1 center (FAB space), 2 on left.
    // In Arabic (RTL), index 0 is rightmost.
    final screenWidth = MediaQuery.of(context).size.width;
    final navWidth = screenWidth - 32; // 16 padding on each side
    // Subtract 3 pixels to account for the Border.all(width: 1.5) on both sides
    final tabWidth = (navWidth - 3) / 5; 

    // Calculate indicator position
    // Indices: 0, 1, (skip 2 for FAB), 2 -> slot 3, 3 -> slot 4
    double getIndicatorPosition(int index) {
      int slot = index;
      if (index > 1) slot = index + 1; // skip center slot
      // Because it's RTL, slot 0 is on the right.
      // Position from Right = slot * tabWidth
      return slot * tabWidth;
    }

    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Glass Background
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Sliding Indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      right: getIndicatorPosition(widget.currentIndex) + (tabWidth / 2) - 25,
                      top: 10,
                      bottom: 10,
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00CFA5).withOpacity(0.15), // Mint Green transparent
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    // Icons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        if (index == 2) {
                          // Empty space for the central FAB
                          return SizedBox(width: tabWidth);
                        }

                        int itemIndex = index > 2 ? index - 1 : index;
                        bool isSelected = widget.currentIndex == itemIndex;

                        return SizedBox(
                          width: tabWidth,
                          child: _BouncyTab(
                            icon: _icons[itemIndex],
                            label: _labels[itemIndex],
                            isSelected: isSelected,
                            onTap: () => widget.onTap(itemIndex),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Central Breathing FAB
          Positioned(
            top: -20, // Hovering above the bar
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B48FF).withOpacity(0.4),
                        blurRadius: _glowAnimation.value,
                        spreadRadius: _glowAnimation.value / 2,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: widget.onFabTap,
                onLongPress: widget.onFabLongPress,
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF00E1D9), Color(0xFF6B48FF)], // Cyan to Purple
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncyTab extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BouncyTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_BouncyTab> createState() => _BouncyTabState();
}

class _BouncyTabState extends State<_BouncyTab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: widget.isSelected ? const Color(0xFF00CFA5) : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                color: widget.isSelected ? const Color(0xFF00CFA5) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glass_bottom_nav.dart';
import 'home/home_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    // Placeholder screens for the other tabs
    const Center(child: Text("شاشة التقارير")),
    const Center(child: Text("شاشة الطوارئ")),
    const Center(child: Text("حسابي")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The current screen
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          
          // The Custom Glass Bottom Navigation Bar
          GlassBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            onFabTap: () {
              // Open AI Assistant / Food Scanner
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري فتح رفيق AI...')),
              );
            },
          ),
        ],
      ),
    );
  }
}

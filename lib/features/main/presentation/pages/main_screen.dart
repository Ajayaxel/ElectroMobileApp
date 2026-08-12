import 'package:flutter/material.dart';
import 'package:electro/features/home/presentation/pages/home_page.dart';
import 'package:electro/features/cart/presentation/pages/cart_screen.dart';
import 'package:electro/features/auth/presentation/pages/profile_page.dart';
import 'package:electro/features/orders/presentation/pages/orders_screen.dart';
import 'package:electro/features/product/presentation/pages/search_screen.dart';
import 'package:electro/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:electro/features/auth/presentation/bloc/auth_state.dart';
import 'package:electro/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchScreen(),
    const CartScreen(),
    const OrdersScreen(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBody: true,
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: Container(
          height: 100,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 65,
                margin: const EdgeInsets.only(bottom: 0),
                decoration: const BoxDecoration(color: Color(0xFF1D7A91)),
                child: Row(
                  children: [
                    _buildNavItem(Icons.home_outlined, 0),
                    _buildNavItem(Icons.search_outlined, 1),
                    _buildNavItem(Icons.shopping_cart_outlined, 2),
                    _buildNavItem(Icons.shopping_bag_outlined, 3),
                    _buildNavItem(Icons.person_outline_rounded, 4),
                  ],
                ),
              ),
              // Animated Indicator (the double circle)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutBack,
                left:
                    (MediaQuery.of(context).size.width / 5) * _selectedIndex +
                    (MediaQuery.of(context).size.width / 10) -
                    35,
                bottom: 30, // Adjust this to overlap the bar
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D7A91),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForIndex(_selectedIndex),
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.search_rounded;
      case 2:
        return Icons.shopping_cart_rounded;
      case 3:
        return Icons.shopping_bag_rounded;
      case 4:
        return Icons.person_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(index),
        child: Opacity(
          opacity: isSelected
              ? 0
              : 1, // Hide the static icon when it's selected (since it's in the floating circle)
          child: Icon(icon, color: Colors.black, size: 28),
        ),
      ),
    );
  }
}

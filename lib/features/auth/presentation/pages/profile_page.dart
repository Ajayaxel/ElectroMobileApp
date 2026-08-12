import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';
import 'package:electro/core/widgets/global_header.dart';
import 'package:electro/features/address/presentation/pages/shipping_address_page.dart';
import 'package:electro/features/orders/presentation/pages/orders_screen.dart';
import 'package:electro/features/wishlist/presentation/pages/wishlist_screen.dart';
import 'settings_page.dart';
import 'edit_profile_page.dart';
import 'my_vehicles_page.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_list_item.dart';
import '../widgets/profile_shimmer.dart';
import 'package:electro/features/home/bloc/home_bloc.dart';
import 'package:electro/features/home/bloc/home_event_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(ProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                if (state is AuthSuccess)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlobalHeader(
                      userName: state.user.name,
                      profileImageUrl: state.user.profileImage,
                    ),
                  ),
                Expanded(child: _buildBody(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
      return const ProfileShimmer();
    }

    if (state is AuthFailure) {
      return _buildErrorState(state.message);
    }

    if (state is AuthSuccess) {
      final user = state.user;
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            // Profile Header
            ProfileHeader(
              name: user.name,
              email: user.email,
              profileImageUrl: user.profileImage,
              onEditTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Account Settings Section
            ProfileSectionCard(
              title: "ACCOUNT SETTINGS",
              children: [
                ProfileListItem(
                  index: 1,
                  icon: Icons.shopping_bag_outlined,
                  title: 'My Orders',
                  subtitle: 'Track your recent purchases',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrdersScreen(),
                    ),
                  ),
                ),
                ProfileListItem(
                  index: 2,
                  icon: Icons.directions_car_outlined,
                  title: 'My Vehicles',
                  subtitle: 'Manage your added vehicles',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyVehiclesPage(),
                    ),
                  ),
                ),
                ProfileListItem(
                  index: 3,
                  icon: Icons.favorite_outline_rounded,
                  title: 'My Wishlist',
                  subtitle: 'Your saved items and favorites',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WishlistScreen(),
                    ),
                  ),
                ),
                ProfileListItem(
                  index: 4,
                  icon: Icons.location_on_outlined,
                  title: 'Shipping Address',
                  subtitle: 'Manage secondary addresses',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShippingAddressPage(),
                    ),
                  ),
                ),
                ProfileListItem(
                  index: 5,
                  icon: Icons.settings_outlined,
                  title: 'App Settings',
                  subtitle: 'Privacy, notifications & cache',
                  showDivider: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Logout Button
            _buildLogoutButton(),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.read<AuthBloc>().add(ProfileRequested()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1D7A91),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {
        context.read<HomeBloc>().add(ResetHome());
        context.read<AuthBloc>().add(LogoutRequested());
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.red[400], size: 20),
            const SizedBox(width: 12),
            Text(
              'Sign Out Account',
              style: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Lufga',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

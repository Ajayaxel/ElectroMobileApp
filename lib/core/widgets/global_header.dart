import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/cart/presentation/pages/cart_screen.dart';

class GlobalHeader extends StatelessWidget {
  final String? greeting;
  final String? userName;
  final String? profileImageUrl;
  final bool hasNotification;
  final bool showBackButton;

  const GlobalHeader({
    super.key,
    this.greeting,
    this.userName,
    this.profileImageUrl,
    this.hasNotification = true,
    this.showBackButton = false,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String displayUserName = userName ?? 'Ajay';
        String displayGreeting = greeting ?? _getGreeting();
        String? displayProfileUrl = profileImageUrl;

        if (state is AuthSuccess) {
          displayUserName = userName ?? state.user.name;
          displayProfileUrl ??= state.user.profileImage;
        }

        return Row(
          children: [
            if (showBackButton) ...[
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[900],
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: ClipOval(
                child: (displayProfileUrl != null && displayProfileUrl.isNotEmpty)
                    ? Image.network(
                        displayProfileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Welcome back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "$displayUserName \ud83d\udc4b",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        );
      },
    );
  }
}

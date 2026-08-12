import 'package:electro/core/theme/app_colors.dart';
import 'package:electro/core/utils/shared_prefs_util.dart';
import 'package:electro/features/auth/domain/repositories/auth_repository.dart';
import 'package:electro/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:electro/features/auth/presentation/bloc/auth_event.dart';
import 'package:electro/features/auth/presentation/pages/login_page.dart';
import 'package:electro/features/home/data/home_repository.dart';
import 'package:electro/features/main/presentation/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:electro/features/cart/data/cart_repository.dart';
import 'package:electro/features/cart/bloc/cart_bloc.dart';
import 'package:electro/features/cart/bloc/cart_event_state.dart';
import 'package:electro/features/address/data/repositories/address_repository.dart';
import 'package:electro/features/address/presentation/bloc/address_bloc.dart';
import 'package:electro/features/address/presentation/bloc/address_event.dart';
import 'package:electro/features/orders/presentation/bloc/order_bloc.dart';
import 'package:electro/features/cart/data/repositories/order_repository.dart';
import 'package:electro/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:electro/features/wishlist/data/wishlist_repository.dart';
import 'package:electro/features/home/bloc/home_bloc.dart';
import 'package:electro/core/network/dio_client.dart';
import 'package:electro/features/auth/presentation/bloc/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await SharedPrefsUtil.isLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final authBloc = AuthBloc(authRepository: AuthRepository());
            DioClient.onUnauthorized = () {
              if (authBloc.state is AuthSuccess) {
                authBloc.add(LogoutRequested());
              }
            };
            return authBloc..add(AppStarted());
          },
        ),
        BlocProvider(
          create: (context) => CartBloc(CartRepository())..add(FetchCart()),
        ),
        BlocProvider(
          create: (context) =>
              AddressBloc(AddressRepository())..add(FetchAddresses()),
        ),
        BlocProvider(
          create: (context) => OrderBloc(orderRepository: OrderRepository()),
        ),
        BlocProvider(
          create: (context) =>
              WishlistBloc(WishlistRepository())..add(FetchWishlist()),
        ),
        BlocProvider(create: (context) => HomeBloc(HomeRepository())),
      ],
      child: MaterialApp(
        title: 'Electro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundDark,
          fontFamily: 'Lufga',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lufga',
            ),
          ),
        ),
        home: isLoggedIn ? const MainScreen() : const LoginPage(),
      ),
    );
  }
}

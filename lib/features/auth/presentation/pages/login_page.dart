import 'package:electro/core/theme/app_colors.dart';
import 'package:electro/core/utils/custom_toast.dart';
import 'package:electro/features/auth/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electro/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:electro/features/auth/presentation/bloc/auth_event.dart';
import 'package:electro/features/auth/presentation/bloc/auth_state.dart';
import 'package:electro/features/auth/presentation/pages/register_page.dart';
import 'package:electro/features/auth/presentation/pages/vehicle_type_selection_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isNavigating = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess && !_isNavigating) {
            _isNavigating = true;
            CustomToast.showSuccess(context, 'Login Successful!');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const VehicleTypeSelectionScreen(),
              ),
              (route) => false,
            );
          } else if (state is AuthFailure) {
            CustomToast.showError(context, state.message);
          }
        },
        child: Column(
          children: [
            const SizedBox(height: 150),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      // Logo
                      Image.asset(
                        'assets/login/electro.png',
                        height: 40,
                        color: Colors.white,
                        errorBuilder: (context, error, stackTrace) =>
                            const Text(
                              'ELECTRO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                      ),
                      const SizedBox(height: 20),
                      // Subtitle
                      const Text(
                        'Login to your account and power your EV,\nsmarter & faster.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Form
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return LoginForm(
                            emailController: _emailController,
                            passwordController: _passwordController,
                            isLoading: state is AuthLoading,
                            onLogin: () {
                              context.read<AuthBloc>().add(
                                LoginRequested(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                ),
                              );
                            },
                            onRegister: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
